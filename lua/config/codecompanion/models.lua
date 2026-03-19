local M = {}

local config_file = vim.fn.stdpath("data") .. "/codecompanion_model_config.json"

-- Static fallback models (used when dynamic fetching fails or as defaults)
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

local static_claude_code = {
  "Opus",
  "Sonnet",
  "Haiku",
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
  opencode = static_opencode,
  ollama = static_ollama,
  claude_code = static_claude_code,
}

-- Cache for dynamic models (loaded lazily)
local models_cache = {
  opencode = nil,
  ollama = nil,
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

local function build_opencode_models(opencode_models)
  local merged = {}
  local seen = {}
  for _, m in ipairs(opencode_models or {}) do
    if not m:find("^openrouter/") and not m:find("%-highspeed$") and not seen[m] then
      table.insert(merged, m)
      seen[m] = true
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
  if adapter == "opencode" then
    local oc_ok, oc_models = pcall(fetch_opencode_models)
    local merged = build_opencode_models(
      oc_ok and oc_models or static_opencode
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
  return "claude_code", "Sonnet"
end

return M
