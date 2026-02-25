local M = {}

local config_file = vim.fn.stdpath("data") .. "/codecompanion_model_config.json"

-- Static fallback models (used when dynamic fetching fails or as defaults)
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
  "qwen/qwen-2.5-coder-32b-instruct:free",
  "meta-llama/llama-3.1-8b-instruct:free",
  "meta-llama/llama-3.3-70b-instruct",
  "deepseek/deepseek-chat",
  "google/gemini-2.5-flash",
}

local static_opencode = {
  -- Direct Anthropic provider
  "anthropic/claude-opus-4-6",
  "anthropic/claude-sonnet-4-5",
  "anthropic/claude-sonnet-4-20250514",
  "anthropic/claude-3-5-sonnet-20241022",
  -- OpenCode native models
  "opencode/minimax-m2.5-free",
  "opencode/anthropic/claude-sonnet-4-20250514",
  "opencode/anthropic/claude-3-5-sonnet-20241022",
  "opencode/anthropic/claude-sonnet-4-5",
  "opencode/anthropic/claude-opus-4-5",
  -- MiniMax via minimax.io
  "minimax/MiniMax-M2.5",
  "minimax/MiniMax-M2.1",
  "minimax/MiniMax-M2",
}

local static_anthropic = {
  "claude-sonnet-4-5-20250929",
  "claude-opus-4-5-20251101",
  "claude-sonnet-4-20250514",
  "claude-3-5-sonnet-20241022",
  "claude-3-5-haiku-20241022",
}

local static_ollama = {
  "qwen2.5-coder:7b",
  "qwen2.5-coder:3b",
  "llama3.2:latest",
  "llama3.1:latest",
  "mistral:latest",
  "codellama:latest",
}

-- Initialize with static models (fast startup)
M.models = {
  openai = static_openai,
  anthropic = static_anthropic,
  opencode = static_opencode,
  ollama = static_ollama,
  openrouter = static_openrouter,
}

-- Cache for dynamic models (loaded lazily)
local models_cache = {
  openai = nil,
  anthropic = nil,
  opencode = nil,
  ollama = nil,
  openrouter = nil,
}

-- Async model fetching functions
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
  for i = 2, #lines do
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

local OPENROUTER_MAX_OUTPUT_COST_PER_M = 2

local function fetch_openrouter_models()
  local max_per_token = OPENROUTER_MAX_OUTPUT_COST_PER_M / 1000000
  local py_script = string.format(
    [[import sys,json;data=json.load(sys.stdin).get('data',[]);]] ..
    [[cost=lambda m:float((m.get('pricing') or {}).get('completion','999') or '999');]] ..
    [[print('\n'.join([m['id'] for m in data if cost(m)<=%s]))]],
    tostring(max_per_token)
  )

  local handle = io.popen(
    "curl -s 'https://openrouter.ai/api/v1/models' 2>/dev/null | python3 -c \"" .. py_script .. "\" 2>/dev/null || echo ''"
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

  -- Try using opencode CLI directly
  if not api_key or api_key == "" then
    local handle = io.popen("opencode models 2>/dev/null")
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

  local endpoint = os.getenv("OPENCODE_API_ENDPOINT") or "https://opencode.ai"

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

local function fetch_anthropic_models()
  local api_key = os.getenv("ANTHROPIC_API_KEY")
  if not api_key or api_key == "" then
    return nil
  end

  local tmpfile = os.tmpname()
  os.execute(string.format(
    'curl -s -H "x-api-key: %s" -H "anthropic-version: 2023-06-01" "https://api.anthropic.com/v1/models?limit=50" > %s 2>/dev/null',
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
      if m.id then
        table.insert(models, m.id)
      end
    end
    return models
  end)

  if not ok or not result then
    return nil
  end

  return result
end

local function build_opencode_models(opencode_models, anthropic_models)
  local merged = {}
  local seen = {}

  local function add(m)
    if not seen[m] then
      table.insert(merged, m)
      seen[m] = true
    end
  end

  for _, m in ipairs(anthropic_models or {}) do
    add("anthropic/" .. m)
  end

  for _, m in ipairs(opencode_models or {}) do
    if not m:find("^openrouter/") and not m:find("%-highspeed$") then
      add(m)
    end
  end

  return merged
end

-- Get available adapters (only those with models)
function M.get_available_adapters()
  local adapters = {}
  for adapter, models in pairs(M.models) do
    if models and #models > 0 then
      table.insert(adapters, adapter)
    end
  end
  return adapters
end

-- Refresh models for a specific adapter (async/lazy)
function M.refresh_models(adapter)
  if adapter == "openai" then
    local ok, result = pcall(fetch_openai_models)
    if ok and result and #result > 0 then
      M.models.openai = result
      models_cache.openai = result
      return true
    end
  elseif adapter == "anthropic" then
    local ok, result = pcall(fetch_anthropic_models)
    if ok and result and #result > 0 then
      M.models.anthropic = result
      models_cache.anthropic = result
      return true
    end
  elseif adapter == "openrouter" then
    local ok, result = pcall(fetch_openrouter_models)
    if ok and result and #result > 0 then
      M.models.openrouter = result
      models_cache.openrouter = result
      return true
    end
  elseif adapter == "opencode" then
    local oc_ok, oc_models = pcall(fetch_opencode_models)
    local an_ok, an_models = pcall(fetch_anthropic_models)
    local merged = build_opencode_models(
      oc_ok and oc_models or static_opencode,
      an_ok and an_models or M.models.anthropic
    )
    M.models.opencode = merged
    models_cache.opencode = merged
    return #merged > 0
  elseif adapter == "ollama" then
    local result = fetch_ollama_models()
    if result and #result > 0 then
      M.models.ollama = result
      models_cache.ollama = result
      return true
    end
  end
  return false
end

-- Get models for adapter (with optional lazy refresh)
function M.get_models(adapter)
  local models = M.models[adapter]
  if models and #models > 0 then
    return models
  end
  -- Try to refresh if empty
  M.refresh_models(adapter)
  return M.models[adapter] or {}
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
  return "openai", "gpt-5.1-mini"
end

return M
