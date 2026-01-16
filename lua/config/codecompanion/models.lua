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

-- Model definitions
M.models = {
  openai = {
    "gpt-5.1",
    "gpt-5.1-mini",
    "gpt-5.1-codex-max",
    "gpt-4.1",
    "gpt-4.1-mini",
    "gpt-4o",
  },
  anthropic = {
    "claude-sonnet-4-5-20250929",
    "claude-opus-4-5-20251101",
    "claude-sonnet-4-20250514",
    "claude-3-5-sonnet-20241022",
    "claude-3-5-haiku-20241022",
  },
  gemini = {
    "gemini-2.5-pro",
    "gemini-2.5-flash",
    "gemini-2.5-flash-lite",
    "gemini-2.0-flash",
  },
  gemini_cli = {
    "gemini-2.5-pro",
    "gemini-2.5-flash",
    "gemini-2.5-flash-lite",
    "gemini-2.0-flash",
    "gemini-3-flash-preview",
  },
  claude_code = {
    "sonnet",
    "opus",
    "haiku",
  },
  ollama = fetch_ollama_models(),
  openrouter = {
    -- Claude (Anthropic)
    "anthropic/claude-sonnet-4.5",
    "anthropic/claude-opus-4.5",
    "anthropic/claude-sonnet-4",
    "anthropic/claude-3.5-sonnet",
    "anthropic/claude-3-opus",
    "anthropic/claude-3-haiku",
    -- OpenAI
    "openai/gpt-5.2-codex",
    "openai/gpt-5.1-codex-max",
    "openai/gpt-5.1-codex",
    "openai/gpt-5.1-codex-mini",
    "openai/gpt-5-codex",
    "openai/codex-mini",
    "openai/gpt-5.1",
    "openai/gpt-5.1-mini",
    "openai/gpt-4o",
    "openai/gpt-4-turbo",
    "openai/gpt-4.1-mini",
    -- Google Gemini
    "google/gemini-2.5-pro",
    "google/gemini-2.5-flash",
    "google/gemini-3-flash-preview",
    -- Qwen (Free tier available)
    "qwen/qwen-2.5-coder-32b-instruct:free",
    "qwen/qwen3-coder:free",
    "qwen/qwen3-32b",
    -- DeepSeek
    "deepseek/deepseek-r1",
    "deepseek/deepseek-chat",
    -- Meta Llama
    "meta-llama/llama-3.3-70b-instruct",
    "meta-llama/llama-3.1-8b-instruct:free",
  },
}

-- Fallback models
if #M.models.ollama == 0 then
  M.models.ollama = { "qwen2.5-coder:7b-base-q6_K", "GandalfBaum/llama3.2-claude3.7:latest" }
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

return M
