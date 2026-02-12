local M = {}

local config_file = vim.fn.stdpath("data") .. "/codecompanion_model_config.json"

local function fetch_ollama_models()
  local handle = io.popen("ollama list 2>/dev/null")
  if not handle then
    return {}
  end

  local output = handle:read("*a")
  local success = handle:close()

  if not success or output == "" then
    return {}
  end

  local models = {}
  local lines = vim.split(output, "\n")
  for i = 2, #lines do -- Skip header
    local line = lines[i]
    if line and line ~= "" then
      local model = line:match("^(%S+)")
      if model then
        table.insert(models, model)
      end
    end
  end
  return models
end

local function fetch_openai_models()
  local api_key = os.getenv("OPENAI_API_KEY")
  if not api_key or api_key == "" then
    return nil
  end

  local tmpfile = os.tmpname()
  os.execute(string.format(
    'curl -s -H "Authorization: Bearer %s" "https://api.openai.com/v1/models?limit=100" > %s 2>/dev/null',
    api_key, tmpfile
  ))

  local file = io.open(tmpfile, "r")
  if not file then
    os.remove(tmpfile)
    return nil
  end

  local content = file:read("*a")
  file:close()
  os.remove(tmpfile)

  if content == "" then
    return nil
  end

  local ok, result = pcall(function()
    local json = vim.json.decode(content)
    local models = {}
    for _, m in ipairs(json.data or {}) do
      local id = m.id
      if id and (id:find("gpt%-4") or id:find("gpt%-3%.5") or id:find("codex") or id:find("o1") or id:find("o3") or id:find("o4")) then
        table.insert(models, id)
      end
    end
    return models
  end)

  if not ok or not result then
    return nil
  end

  return result
end

local function fetch_openrouter_models()
  local handle = io.popen(
    "curl -s 'https://openrouter.ai/api/v1/models' 2>/dev/null | python3 -c \"import sys,json;print('\\n'.join([m['id'] for m in json.load(sys.stdin)['data'][:100]]))\" 2>/dev/null || echo ''"
  )

  if not handle then
    return nil
  end

  local output = handle:read("*a")
  local success = handle:close()

  if not success or output == "" then
    return nil
  end

  local models = {}
  for line in output:gmatch("[^\n]+") do
    if line and line ~= "" then
      table.insert(models, line)
    end
  end
  return models
end

local function fetch_opencode_models()
  local api_key = os.getenv("OPENCODE_API_KEY")
  local endpoint = os.getenv("OPENCODE_API_ENDPOINT") or "https://opencode.ai"

  if not api_key or api_key == "" then
    return nil
  end

  local handle = io.popen(string.format(
    [[curl -s -H "Authorization: Bearer %s" "%s/api/v1/models" 2>/dev/null | python3 -c "import sys,json;models=json.load(sys.stdin).get('data',[]);print('\\n'.join([m.get('id',m.get('name','')) for m in models]))" 2>/dev/null || echo '']],
    api_key, endpoint
  ))

  if not handle then
    return nil
  end

  local output = handle:read("*a")
  local success = handle:close()

  if not success or output == "" then
    return nil
  end

  local models = {}
  for line in output:gmatch("[^\n]+") do
    if line and line ~= "" then
      table.insert(models, line)
    end
  end
  return models
end

-- Static fallback models (used when dynamic fetching fails)
local static_openai = {
  "gpt-5.1",
  "gpt-5.1-mini",
  "gpt-5.1-codex-max",
  "gpt-4.1",
  "gpt-4.1-mini",
  "gpt-4o",
  "gpt-4-turbo",
  "o1",
  "o3-mini",
}

local static_openrouter = {
  "anthropic/claude-sonnet-4.5",
  "anthropic/claude-opus-4.5",
  "anthropic/claude-sonnet-4",
  "anthropic/claude-3.5-sonnet",
  "anthropic/claude-3-opus",
  "anthropic/claude-3-haiku",
  "openai/gpt-5.1",
  "openai/gpt-4o",
  "google/gemini-2.5-pro",
  "deepseek/deepseek-r1",
  "qwen/qwen-2.5-coder-32b-instruct:free",
  "meta-llama/llama-3.3-70b-instruct",
}

local static_opencode = {
  "minimax/MiniMax-M2.1",
  "minimax/MiniMax-M2",
  "openrouter/anthropic/claude-sonnet-4.5",
  "openrouter/anthropic/claude-3.5-sonnet",
  "openrouter/anthropic/claude-opus-4.5",
  "openrouter/anthropic/claude-sonnet-4",
  "openrouter/openai/gpt-5.1-codex-mini",
  "openrouter/openai/gpt-5.1-codex",
  "openrouter/openai/gpt-5.1-codex-max",
  "openrouter/openai/gpt-5.1",
  "openrouter/openai/gpt-4o",
  "openrouter/openai/gpt-4.1-mini",
  "openrouter/google/gemini-2.5-pro",
  "openrouter/google/gemini-2.5-flash",
  "openrouter/google/gemini-3-flash-preview",
  "openrouter/qwen/qwen-2.5-coder-32b-instruct:free",
  "openrouter/deepseek/deepseek-r1",
  "openrouter/deepseek/deepseek-chat",
  "openrouter/meta-llama/llama-3.3-70b-instruct",
  "openrouter/meta-llama/llama-3.1-8b-instruct:free",
}

local static_anthropic = {
  "claude-sonnet-4-5-20250929",
  "claude-opus-4-5-20251101",
  "claude-sonnet-4-20250514",
  "claude-3-5-sonnet-20241022",
  "claude-3-5-haiku-20241022",
}

-- Dynamic model fetching (with fallback to static)
local ok_openai, dynamic_openai = pcall(fetch_openai_models)
local ok_openrouter, dynamic_openrouter = pcall(fetch_openrouter_models)
local ok_opencode, dynamic_opencode = pcall(fetch_opencode_models)

-- Combine OpenRouter models with OpenCode for unified access
local function merge_openrouter_to_opencode(opencode_models, openrouter_models)
  if not openrouter_models or #openrouter_models == 0 then
    return opencode_models
  end

  local merged = {}
  local seen = {}

  -- First add OpenCode native models
  for _, m in ipairs(opencode_models or {}) do
    table.insert(merged, m)
    seen[m] = true
  end

  -- Then add OpenRouter models (filtered to common providers)
  local providers = { "anthropic", "openai", "google", "deepseek", "meta-llama", "qwen" }
  for _, m in ipairs(openrouter_models) do
    if not seen[m] then
      for _, p in ipairs(providers) do
        if m:find("^" .. p .. "/") then
          table.insert(merged, m)
          seen[m] = true
          break
        end
      end
    end
  end

  return merged
end

-- Model definitions
M.models = {
  openai = ok_openai and dynamic_openai or static_openai,
  anthropic = static_anthropic,
  opencode = merge_openrouter_to_opencode(
    ok_opencode and dynamic_opencode or static_opencode,
    ok_openrouter and dynamic_openrouter or static_openrouter
  ),
  ollama = fetch_ollama_models(),
  openrouter = ok_openrouter and dynamic_openrouter or static_openrouter,
}

-- Fallback models (when dynamic fetching returns empty)
if #M.models.ollama == 0 then
  M.models.ollama = {
    "qwen2.5-coder:7b",
    "qwen2.5-coder:3b",
    "llama3.2:latest",
    "llama3.1:latest",
    "mistral:latest",
    "codellama:latest",
  }
end

if #M.models.openai == 0 then
  M.models.openai = static_openai
end

if #M.models.openrouter == 0 then
  M.models.openrouter = static_openrouter
end

if #M.models.opencode == 0 then
  M.models.opencode = static_opencode
end

-- Persistence functions
function M.save_model_preference(adapter, model)
  local config = { current_adapter = adapter, current_model = model }
  local file = io.open(config_file, "w")
  if file then
    file:write(vim.json.encode(config))
    file:close()
  end
end

function M.load_model_preference()
  local file = io.open(config_file, "r")
  if file then
    local content = file:read("*a")
    file:close()
    local ok, config = pcall(vim.json.decode, content)
    if ok and config then
      return config.current_adapter, config.current_model
    end
  end
  return "openai", "gpt-5.1-mini" -- defaults
end

function M.refresh_models(adapter)
  if adapter == "openai" then
    local ok, models = pcall(fetch_openai_models)
    if ok and models and #models > 0 then
      M.models.openai = models
      return true
    end
  elseif adapter == "openrouter" then
    local ok, models = pcall(fetch_openrouter_models)
    if ok and models and #models > 0 then
      M.models.openrouter = models
      return true
    end
  elseif adapter == "opencode" then
    local ok, models = pcall(fetch_opencode_models)
    if ok and models and #models > 0 then
      M.models.opencode = models
      return true
    end
  elseif adapter == "ollama" then
    M.models.ollama = fetch_ollama_models()
    return #M.models.ollama > 0
  end
  return false
end

function M.get_available_adapters()
  local adapters = {}
  for adapter, models in pairs(M.models) do
    if #models > 0 then
      table.insert(adapters, adapter)
    end
  end
  return adapters
end

return M
