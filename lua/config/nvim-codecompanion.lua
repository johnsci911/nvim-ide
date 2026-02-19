local prompts = require("config.codecompanion.prompts")
local models_module = require("config.codecompanion.models")

local SYSTEM_PROMPT = prompts.SYSTEM_PROMPT
local EXPLAIN = prompts.EXPLAIN
local REVIEW = prompts.REVIEW
local REFACTOR = prompts.REFACTOR

local models = models_module.models
local save_model_preference = models_module.save_model_preference
local load_model_preference = models_module.load_model_preference


-- Fallback models
if #models.ollama == 0 then
  models.ollama = { "qwen2.5-coder:7b-base-q6_K", "GandalfBaum/llama3.2-claude3.7:latest" }
end

-- Initialize global config early to avoid undefined references
_G.codecompanion_config = {
  interactions = { chat = { adapter = "openai" } },
  adapters = {
    http = {},
  },
}

-- Simple global state for current adapter/model (updated by apply_model_config)
_G.codecompanion_current_state = {
  adapter = "openai",
  model = "gpt-4.1-mini"
}

-- Provider billing metadata — makes it UNMISSABLE which account gets charged
local provider_meta = {
  openai      = { label = "PAID",  billing = "OpenAI Account",           hl = "DiagnosticWarn"  },
  anthropic   = { label = "PAID",  billing = "Anthropic Account",        hl = "DiagnosticWarn"  },
  openrouter  = { label = "PAID",  billing = "OpenRouter Account",       hl = "DiagnosticError" },
  ollama      = { label = "FREE",  billing = "Local Machine",            hl = "DiagnosticOk"    },
  gemini      = { label = "PAID",  billing = "Google AI Studio",         hl = "DiagnosticWarn"  },
  gemini_cli  = { label = "FREE",  billing = "Google OAuth (Free Tier)", hl = "DiagnosticOk"    },
  opencode    = { label = "PAID",  billing = "OpenCode Account",         hl = "DiagnosticWarn"  },
}

-- Helper functions (defined early to avoid reference errors)
local function get_current_adapter()
  local adapter = _G.codecompanion_config.interactions.chat.adapter
  if type(adapter) == "table" then
    return adapter.name or "openai"
  end
  return adapter or "openai"
end

local function get_current_model_name()
  local adapter_name = get_current_adapter()

  -- Handle ACP adapters (like gemini_cli) which may have model in interactions
  if adapter_name == "gemini_cli" then
    local chat_adapter = _G.codecompanion_config.interactions.chat.adapter
    if type(chat_adapter) == "table" and chat_adapter.model then
      return chat_adapter.model
    end
    -- Check ACP adapter defaults
    local acp_adapters = _G.codecompanion_config.adapters.acp
    if acp_adapters and acp_adapters.gemini_cli then
      local adapter = acp_adapters.gemini_cli()
      if adapter.defaults and adapter.defaults.model then
        return adapter.defaults.model
      end
    end
    return "gemini-2.5-pro" -- default
  elseif adapter_name == "opencode" then
    local chat_adapter = _G.codecompanion_config.interactions.chat.adapter
    if type(chat_adapter) == "table" and chat_adapter.model then
      return chat_adapter.model
    end
    -- Check ACP adapter defaults
    local acp_adapters = _G.codecompanion_config.adapters.acp
    if acp_adapters and acp_adapters.opencode then
      local adapter = acp_adapters.opencode()
      if adapter.defaults and adapter.defaults.model then
        return adapter.defaults.model
      end
    end
    return "opencode" -- default
  end



  -- Handle HTTP adapters
  local adapter_fn = _G.codecompanion_config.adapters.http[adapter_name]
  if adapter_fn then
    local adapter = adapter_fn()
    return adapter.schema and adapter.schema.model and adapter.schema.model.default or "unknown"
  end
  return "unknown"
end

local function get_current_model()
  local adapter = get_current_adapter()
  local model = get_current_model_name()
  local icons = { openai = "🚀", anthropic = "💡", ollama = "🐑", openrouter = "🌐", opencode = "⚡", }
  return (icons[adapter] or "🤖") .. " " .. model
end

local function get_intro_message()
  local adapter_name = _G.codecompanion_current_state.adapter
  local model_name = _G.codecompanion_current_state.model
  local icons = { openai = "🚀", anthropic = "💡", ollama = "🐑", openrouter = "🌐", opencode = "⚡", }
  local icon = icons[adapter_name] or "✨"

  local display_name = adapter_name:gsub("^%l", string.upper)
  if adapter_name == "opencode" then
    display_name = "OpenCode CLI"
  end

  return icon .. " Using " .. display_name .. ": " .. model_name .. ". Press ? for options " .. icon
end

local function show_provider_banner(adapter_name, model_name)
  local meta = provider_meta[adapter_name] or { label = "UNKNOWN", billing = "Unknown", hl = "DiagnosticInfo" }
  local is_paid = meta.label ~= "FREE"

  local billing_note = meta.billing
  if adapter_name == "opencode" then
    if model_name:match("^openrouter/") then
      billing_note = "ROUTED VIA OPENROUTER!"
    elseif model_name:match("^anthropic/") then
      billing_note = "DIRECT ANTHROPIC (your Anthropic key)"
    elseif model_name:match("^opencode/") then
      billing_note = "OpenCode Account"
    end
  end

  local header = is_paid and "  WARNING: PAID PROVIDER ACTIVE" or "  FREE PROVIDER ACTIVE"
  local cost_line = is_paid and "  Status  : PAID" or "  Status  : FREE"

  local lines = {
    "",
    header,
    "  " .. string.rep(is_paid and "=" or "-", 42),
    "",
    "  Provider : " .. adapter_name:gsub("^%l", string.upper),
    "  Model    : " .. model_name,
    "  Billing  : " .. billing_note,
    cost_line,
    "",
    "  Press any key to dismiss (auto-close 4s)",
    "",
  }

  local max_line_len = 0
  for _, line in ipairs(lines) do
    max_line_len = math.max(max_line_len, #line)
  end
  local width = math.max(max_line_len + 6, 52)
  local height = #lines

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = "wipe"

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = "minimal",
    border = is_paid and "double" or "rounded",
    title = is_paid and " BILLING ALERT " or " PROVIDER INFO ",
    title_pos = "center",
  })

  local win_hl = is_paid
    and "Normal:DiagnosticError,FloatBorder:DiagnosticError"
    or  "Normal:DiagnosticOk,FloatBorder:DiagnosticOk"
  vim.api.nvim_set_option_value("winhl", win_hl, { win = win })

  vim.api.nvim_buf_add_highlight(buf, -1, is_paid and "ErrorMsg" or "String", 1, 0, -1)
  vim.api.nvim_buf_add_highlight(buf, -1, is_paid and "ErrorMsg" or "String", 2, 0, -1)

  local closed = false
  local function close_banner()
    if not closed and vim.api.nvim_win_is_valid(win) then
      closed = true
      vim.api.nvim_win_close(win, true)
    end
  end

  for _, key in ipairs({ "<Esc>", "q", "<CR>", "<Space>", "<BS>" }) do
    vim.keymap.set("n", key, close_banner, { buffer = buf, nowait = true })
  end

  vim.defer_fn(close_banner, 4000)
end

local function confirm_paid_switch(adapter_name, model_name, on_confirm)
  local meta = provider_meta[adapter_name] or { label = "UNKNOWN", billing = "Unknown" }
  local is_paid = meta.label ~= "FREE"

  if adapter_name == "opencode" and model_name:match("^openrouter/") then
    is_paid = true
  end

  if adapter_name == "opencode" and model_name:match("^anthropic/") then
    is_paid = true
  end

  if not is_paid then
    on_confirm()
    return
  end

  vim.ui.select(
    {
      "Yes - switch to " .. adapter_name:gsub("^%l", string.upper) .. " (" .. meta.billing .. ")",
      "Cancel",
    },
    {
      prompt = "PAID PROVIDER: " .. adapter_name:gsub("^%l", string.upper)
        .. " | Billing: " .. meta.billing
        .. " | Model: " .. model_name
        .. " — Continue?",
    },
    function(choice)
      if choice and choice:match("^Yes") then
        on_confirm()
      else
        vim.notify("Switch cancelled", vim.log.levels.INFO)
      end
    end
  )
end

local function apply_model_config(adapter_name, model_name)
  -- Update the simple global state first (this is what get_intro_message reads)
  _G.codecompanion_current_state.adapter = adapter_name
  _G.codecompanion_current_state.model = model_name

  -- Update the intro_message string in config (CodeCompanion expects a string, not a function)
  _G.codecompanion_config.display.chat.intro_message = get_intro_message()

  -- Handle ACP adapters (like gemini_cli) differently
  if adapter_name == "gemini_cli" then
    -- Update the ACP adapter with the new model
    _G.codecompanion_config.adapters.acp = _G.codecompanion_config.adapters.acp or {}
    _G.codecompanion_config.adapters.acp.gemini_cli = function()
      return require("codecompanion.adapters").extend("gemini_cli", {
        defaults = {
          auth_method = "oauth-personal",
          model = model_name,
        },
      })
    end

    -- For ACP adapters, use the { name, model } format in interactions
    local adapter_config = { name = "gemini_cli", model = model_name }
    _G.codecompanion_config.interactions.chat.adapter = adapter_config
    _G.codecompanion_config.interactions.inline.adapter = adapter_config
    _G.codecompanion_config.interactions.agent.adapter = adapter_config

    -- Refresh CodeCompanion with updated config
    local codecompanion = require("codecompanion")
    if codecompanion.adapters_cache then
      codecompanion.adapters_cache["gemini_cli"] = nil
    end
    codecompanion.setup(_G.codecompanion_config)
    return
  elseif adapter_name == "opencode" then
    -- Update the ACP adapter with the new model
    _G.codecompanion_config.adapters.acp = _G.codecompanion_config.adapters.acp or {}
    _G.codecompanion_config.adapters.acp.opencode = function()
      return require("codecompanion.adapters").extend("opencode", {
        defaults = {
          model = model_name,
        },
      })
    end

    -- For ACP adapters, use the { name, model } format in interactions
    local adapter_config = { name = "opencode", model = model_name }
    _G.codecompanion_config.interactions.chat.adapter = adapter_config
    _G.codecompanion_config.interactions.inline.adapter = adapter_config
    _G.codecompanion_config.interactions.agent.adapter = adapter_config

    -- Refresh CodeCompanion with updated config
    local codecompanion = require("codecompanion")
    if codecompanion.adapters_cache then
      codecompanion.adapters_cache["opencode"] = nil
    end
    codecompanion.setup(_G.codecompanion_config)
    return
  end


  -- Handle HTTP adapters (existing logic)
  local adapters = _G.codecompanion_config.adapters.http
  local adapter_fn = adapters[adapter_name]
  if adapter_fn then
    local adapter = adapter_fn()
    if adapter.schema and adapter.schema.model then
      adapter.schema.model.default = model_name
    end
    if adapter_name == "openrouter" then
      adapter.env.api_key = os.getenv("OPENROUTER_API_KEY")
    elseif adapter_name == "gemini" then
      adapter.env.api_key = os.getenv("GEMINI_API_KEY")
    end
    adapters[adapter_name] = function()
      return adapter
    end
  else
    adapters[adapter_name] = function()
      local base_env = {}
      local schema = { model = { default = model_name } }
      if adapter_name == "ollama" then
        base_env = { url = "http://127.0.0.1:11434" }
        schema.num_ctx = { default = 16384 }
      elseif adapter_name == "openai" then
        base_env = { OPENAI_API_KEY = os.getenv("OPENAI_API_KEY") }
        schema.temperature = { default = 0 }
        schema.max_tokens = { default = 16384 }
      elseif adapter_name == "anthropic" then
        base_env = { ANTHROPIC_API_KEY = os.getenv("ANTHROPIC_API_KEY") }
      elseif adapter_name == "gemini" then
        base_env = { api_key = os.getenv("GEMINI_API_KEY") }
      elseif adapter_name == "openrouter" then
        base_env = {
          url = "https://openrouter.ai/api",
          api_key = os.getenv("OPENROUTER_API_KEY"),
          chat_url = "/v1/chat/completions",
        }
      end
      return require("codecompanion.adapters").extend(adapter_name, {
        env = base_env,
        schema = schema,
      })
    end
  end

  -- Update all interactions
  for _, interaction in pairs(_G.codecompanion_config.interactions) do
    interaction.adapter = adapter_name
  end


  -- Clear caches and re-setup
  local codecompanion = require("codecompanion")
  if codecompanion.adapters_cache then
    codecompanion.adapters_cache[adapter_name] = nil
  end
  codecompanion.setup(_G.codecompanion_config)
end

-- Enhanced model switching with better UX
local function switch_model()
  local available_adapters = {}
  for adapter_name, model_list in pairs(models) do
    if model_list and #model_list > 0 then
      local status = adapter_name == get_current_adapter() and " (current)" or ""
      table.insert(available_adapters, adapter_name .. status)
    end
  end

  if #available_adapters == 0 then
    vim.notify("No adapters with available models found", vim.log.levels.WARN)
    return
  end

  require('telescope.pickers').new({}, {
    prompt_title = "AI Providers (PAID = billed to your account)",
    layout_config = {
      width = 0.6,
      height = 0.4
    },
    finder = require('telescope.finders').new_table({
      results = available_adapters,
      entry_maker = function(entry)
        local adapter = entry:gsub(" %(current%)", "")
        local meta = provider_meta[adapter] or { label = "?", billing = "Unknown" }
        local icon = adapter == "openai" and "🚀" or
            adapter == "anthropic" and "💡" or
            adapter == "ollama" and "🐑" or
            adapter == "openrouter" and "🌐" or
            adapter == "opencode" and "⚡" or
            "💻"
        local cost_tag = meta.label == "FREE"
            and " [FREE]"
            or  " [PAID - " .. meta.billing .. "]"
        return {
          value = entry,
          display = icon .. " " .. adapter:gsub("^%l", string.upper) .. cost_tag,
          ordinal = entry
        }
      end
    }),
    sorter = require('telescope.sorters').get_generic_fuzzy_sorter(),
    attach_mappings = function(prompt_bufnr, map)
      map('i', '<CR>', function()
        local selection = require('telescope.actions.state').get_selected_entry()
        require('telescope.actions').close(prompt_bufnr)

        local adapter_name = selection.value:match("^[^%s]+"):gsub(" %(current%)", "")
        local available_models = models[adapter_name]

        local meta = provider_meta[adapter_name] or { label = "?", billing = "Unknown" }
        local picker_title = "Models: " .. adapter_name:gsub("^%l", string.upper)
            .. " [" .. meta.label .. " - " .. meta.billing .. "]"

        require('telescope.pickers').new({}, {
          prompt_title = picker_title,
          layout_config = {
            width = 0.6,
            height = 0.4
          },
          finder = require('telescope.finders').new_table({
            results = available_models,
            entry_maker = function(model)
              local saved_adapter, saved_model = load_model_preference()
              local current_model = nil
              if saved_adapter == adapter_name then
                current_model = saved_model
              elseif get_current_adapter() == adapter_name then
                current_model = get_current_model_name()
              end
              local prefix = model == current_model and "✓ " or "  "
              local suffix = ""
              if adapter_name == "opencode" then
                if model:match("^openrouter/") then
                  suffix = "  [VIA OPENROUTER $$]"
                elseif model:match("^anthropic/") then
                  suffix = "  [DIRECT ANTHROPIC]"
                elseif model:match("^opencode/") then
                  suffix = "  [VIA OPENCODE]"
                elseif model:match("^minimax/") then
                  suffix = "  [MINIMAX]"
                end
              end
              return {
                value = model,
                display = prefix .. model .. suffix,
                ordinal = model
              }
            end
          }),
          sorter = require('telescope.sorters').get_generic_fuzzy_sorter(),
          attach_mappings = function(model_prompt_bufnr, model_map)
            model_map('i', '<CR>', function()
              local model_selection = require('telescope.actions.state').get_selected_entry()
              require('telescope.actions').close(model_prompt_bufnr)

              confirm_paid_switch(adapter_name, model_selection.value, function()
                apply_model_config(adapter_name, model_selection.value)
                save_model_preference(adapter_name, model_selection.value)
                show_provider_banner(adapter_name, model_selection.value)
              end)
            end)
            return true
          end
        }):find()
      end)
      return true
    end
  }):find()
end

_G.get_git_diff = function()
  local output = vim.fn.system("git diff")
  if type(output) == "table" then
    -- If it's a table, join it with newlines
    return table.concat(output, "\n")
  end
  return output
end

_G.get_git_staged_diff = function()
  local output = vim.fn.system("git diff --staged")
  if type(output) == "table" then
    -- If it's a table, join it with newlines
    return table.concat(output, "\n")
  end
  return output
end

local function quick_switch_to_gpt4()
  local model = "gpt-4.1-mini"
  confirm_paid_switch("openai", model, function()
    apply_model_config("openai", model)
    save_model_preference("openai", model)
    show_provider_banner("openai", model)
  end)
end

local function quick_switch_to_claude()
  local model = "claude-3-5-sonnet-20241022"
  confirm_paid_switch("anthropic", model, function()
    apply_model_config("anthropic", model)
    save_model_preference("anthropic", model)
    show_provider_banner("anthropic", model)
  end)
end

local function quick_switch_to_local()
  local model = models.ollama[1] or "qwen2.5-coder:7b-base-q6_K"
  apply_model_config("ollama", model)
  save_model_preference("ollama", model)
  show_provider_banner("ollama", model)
end

local function quick_switch_to_gemini()
  local model = "gemini-2.0-flash-exp"
  confirm_paid_switch("gemini", model, function()
    apply_model_config("gemini", model)
    save_model_preference("gemini", model)
    show_provider_banner("gemini", model)
  end)
end

local function quick_switch_to_openrouter()
  local model = "qwen/qwen-2.5-coder-32b-instruct:free"
  confirm_paid_switch("openrouter", model, function()
    apply_model_config("openrouter", model)
    save_model_preference("openrouter", model)
    show_provider_banner("openrouter", model)
  end)
end

local function quick_switch_to_gemini_cli()
  local default_model = models.gemini_cli[1] or "gemini-2.5-pro"
  apply_model_config("gemini_cli", default_model)
  save_model_preference("gemini_cli", default_model)
  show_provider_banner("gemini_cli", default_model)
end

local function quick_switch_to_opencode()
  local default_model = models.opencode[1] or "opencode"
  confirm_paid_switch("opencode", default_model, function()
    apply_model_config("opencode", default_model)
    save_model_preference("opencode", default_model)
    show_provider_banner("opencode", default_model)
  end)
end

vim.api.nvim_create_user_command("CCSwitchModel", switch_model, { desc = "Switch AI model" })
vim.api.nvim_create_user_command("CCQuickGPT4", quick_switch_to_gpt4, { desc = "Quick switch to GPT-4 mini" })
vim.api.nvim_create_user_command("CCQuickClaude", quick_switch_to_claude, { desc = "Quick switch to Claude" })
vim.api.nvim_create_user_command("CCQuickLocal", quick_switch_to_local, { desc = "Quick switch to local model" })
vim.api.nvim_create_user_command("CCQuickOpenRouter", quick_switch_to_openrouter, { desc = "Quick switch to OpenRouter" })
vim.api.nvim_create_user_command("CCQuickOpenCode", quick_switch_to_opencode, { desc = "Quick switch to OpenCode CLI" })
vim.api.nvim_create_user_command("CCCurrentModel", function()
  vim.notify("Current model: " .. get_current_model(), vim.log.levels.INFO)
end, { desc = "Show current model" })
vim.api.nvim_create_user_command("CCRefreshModels", function()
  local m = require("config.codecompanion.models")
  local results = {}
  for _, adapter in ipairs({ "anthropic", "openai", "openrouter", "ollama", "opencode" }) do
    local ok = m.refresh_models(adapter)
    local count = m.models[adapter] and #m.models[adapter] or 0
    table.insert(results, adapter .. ": " .. (ok and (count .. " models") or "failed"))
  end
  vim.notify("Refresh complete\n" .. table.concat(results, "\n"), vim.log.levels.INFO)
end, { desc = "Refresh AI models from all providers" })
vim.api.nvim_create_user_command("CCListAdapters", function()
  local m = require("config.codecompanion.models")
  local lines = {}
  for adapter, model_list in pairs(m.models) do
    local meta = provider_meta[adapter]
    local tag = meta and meta.label or "?"
    table.insert(lines, string.format("%-12s [%s]  %d models", adapter, tag, #model_list))
  end
  table.sort(lines)
  vim.notify("Adapters:\n" .. table.concat(lines, "\n"), vim.log.levels.INFO)
end, { desc = "List adapters with model counts and billing" })

_G.paste_image_from_clipboard = function()
  local chat_bufnr = vim.api.nvim_get_current_buf()

  local codecompanion = require("codecompanion")
  local chat_obj = codecompanion.buf_get_chat(chat_bufnr)
  if not chat_obj then
    vim.notify("No active chat buffer", vim.log.levels.WARN)
    return
  end

  local temp_file = vim.fn.tempname() .. ".png"

  local success = false
  if vim.fn.has("macunix") == 1 then
    if vim.fn.executable("pngpaste") == 1 then
      vim.fn.system("pngpaste " .. temp_file)
      success = vim.v.shell_error == 0 and vim.fn.filereadable(temp_file) == 1
    else
      vim.notify("Install pngpaste (brew install pngpaste) for clipboard images on macOS", vim.log.levels.WARN)
      return
    end
  elseif vim.fn.has("unix") == 1 then
    if vim.fn.executable("xclip") == 1 then
      vim.fn.system("xclip -selection clipboard -t image/png -o > " .. temp_file)
      success = vim.v.shell_error == 0 and vim.fn.filereadable(temp_file) == 1
    elseif vim.fn.executable("wl-paste") == 1 then
      vim.fn.system("wl-paste -t image/png > " .. temp_file)
      success = vim.v.shell_error == 0 and vim.fn.filereadable(temp_file) == 1
    end

    if not success then
      vim.notify("Clipboard image not available. Install img-clip.nvim for better support.", vim.log.levels.WARN)
      return
    end
  else
    vim.notify("Clipboard images not supported on this platform", vim.log.levels.WARN)
    return
  end

  local image_utils = require("codecompanion.utils.images")
  local encoded = image_utils.encode_image({ path = temp_file })
  if type(encoded) == "string" then
    vim.notify("Failed to encode image: " .. encoded, vim.log.levels.ERROR)
    return
  end

  local ok, err = pcall(function()
    chat_obj:add_image_message(encoded)
  end)

  if not ok then
    vim.notify("Failed to add image to chat: " .. err, vim.log.levels.ERROR)
  end
end

_G.get_codecompanion_status = function()
  return get_current_model()
end

_G.codecompanion_config = vim.tbl_deep_extend("force", _G.codecompanion_config, {
  opts = { system_prompt = SYSTEM_PROMPT, log_level = "ERROR" },
  display = {
    diff = {
      enabled = true,
      close_chat_at = 240,
      layout = "vertical",
      opts = { "internal", "filler", "closeoff", "algorithm:patience", "followwrap", "linematch:120" },
      provider = "mini_diff",
    },
    chat = {
      intro_message = get_intro_message(),
      show_header_separator = false,
      separator = "─",
      show_references = true,
      show_settings = false,
      show_token_count = true,
      start_in_insert_mode = false,
      window = { layout = "vertical" },
    },
  },
  diff = {
    enabled = true,
    close_chat_at = 240,
    layout = "vertical",
    opts = { "internal", "filler", "closeoff", "algorithm:patience", "followwrap", "linematch:120" },
    provider = "mini_diff",
  },
  extensions = {
    mcphub = {
      callback = "mcphub.extensions.codecompanion",
      opts = {
        make_vars = true,
        make_slash_commands = true,
        show_result_in_chat = true,
      },
    },
    history = {
      enabled = true,
      opts = {
        -- Keymap to open history from chat buffer (default: gh)
        keymap = "gh",
        -- Keymap to save the current chat manually (when auto_save is disabled)
        save_chat_keymap = "sc",
        -- Save all chats by default (disable to save only manually using 'sc')
        auto_save = true,
        -- Number of days after which chats are automatically deleted (0 to disable)
        expiration_days = 0,
        -- Picker interface (auto resolved to a valid picker)
        picker = "telescope", --- ("telescope", "snacks", "fzf-lua", or "default")
        ---Optional filter function to control which chats are shown when browsing
        chat_filter = nil,    -- function(chat_data) return boolean end
        -- Customize picker keymaps (optional)
        picker_keymaps = {
          rename = { n = "r", i = "<M-r>" },
          delete = { n = "d", i = "<M-d>" },
          duplicate = { n = "<C-y>", i = "<C-y>" },
        },
        ---Automatically generate titles for new chats
        auto_generate_title = false,
        title_generation_opts = {
          ---Adapter for generating titles (use HTTP adapter since ACP doesn't support this)
          adapter = "gemini",
          ---Model for generating titles
          model = "gemini-2.5-flash",
          ---Number of user prompts after which to refresh the title (0 to disable)
          refresh_every_n_prompts = 0, -- e.g., 3 to refresh after every 3rd user prompt
          ---Maximum number of times to refresh the title (default: 3)
          max_refreshes = 3,
          format_title = function(original_title)
            -- this can be a custom function that applies some custom
            -- formatting to the title.
            return original_title
          end
        },
        ---On exiting and entering neovim, loads the last chat on opening chat
        continue_last_chat = false,
        ---When chat is cleared with `gx` delete the chat from history
        delete_on_clearing_chat = false,
        ---Directory path to save the chats
        dir_to_save = vim.fn.stdpath("data") .. "/codecompanion-history",
        ---Enable detailed logging for history extension
        enable_logging = false,

        -- Summary system
        summary = {
          -- Keymap to generate summary for current chat (default: "gcs")
          create_summary_keymap = "gcs",
          -- Keymap to browse summaries (default: "gbs")
          browse_summaries_keymap = "gbs",

          generation_opts = {
            adapter = nil,               -- defaults to current chat adapter
            model = nil,                 -- defaults to current chat model
            context_size = 90000,        -- max tokens that the model supports
            include_references = true,   -- include slash command content
            include_tool_outputs = true, -- include tool execution results
            system_prompt = nil,         -- custom system prompt (string or function)
            format_summary = nil,        -- custom function to format generated summary e.g to remove <think/> tags from summary
          },
        },

        -- Memory system (requires VectorCode CLI)
        memory = {
          -- Automatically index summaries when they are generated
          auto_create_memories_on_summary_generation = true,
          -- Path to the VectorCode executable
          vectorcode_exe = "vectorcode",
          -- Tool configuration
          tool_opts = {
            -- Default number of memories to retrieve
            default_num = 10
          },
          -- Enable notifications for indexing progress
          notify = true,
          -- Index all existing memories on startup
          -- (requires VectorCode 0.6.12+ for efficient incremental indexing)
          index_on_startup = false,
        },
      }
    }
  },
  tools = {
    -- Enable the insert_edit_into_file tool for applying changes from chat
    insert_edit_into_file = {
      enabled = true,
      opts = {
        -- Require approval before editing buffers (default: false)
        require_approval_before = {
          buffer = true,  -- Ask before editing open buffers
          file = true,    -- Ask before editing files
        },
        -- Require confirmation after execution (default: true)
        require_confirmation_after = true,
      },
    },
  },
  interactions = {
    chat = {
      adapter = "openai",
      roles = {
        llm = function(adapter) return get_current_model() end,
        user = "Me:",
      },
      keymaps = {
        send = {
          modes = {
            n = "<CR>",
            i = "<C-s>",
          },
          index = 1,
          callback = "keymaps.send",
          description = "Send",
        },
        close = {
          modes = {
            n = "q",
          },
          index = 3,
          callback = "keymaps.close",
          description = "Close Chat",
        },
        stop = {
          modes = {
            n = "<C-c>",
          },
          index = 4,
          callback = "keymaps.stop",
          description = "Stop Request",
        },
        paste_image = {
          modes = {
            n = "<leader>aip",
            i = "<leader>aip",
          },
          index = 100,
          callback = function()
            _G.paste_image_from_clipboard()
          end,
          description = "Paste image from clipboard",
        },
      },
      slash_commands = {
        image = {
          opts = {
            provider = "snacks",
          },
        },
      },
    },
    inline = {
      adapter = "openai",
    },
    agent = {
      adapter = "openai",
    },
  },
  adapters = {
    http = {
      opts = {
        show_model_choices = true,
      },
      ollama = function()
        return require("codecompanion.adapters").extend("ollama", {
          env = {
            url = "http://127.0.0.1:11434",
          },
          schema = {
            model = {
              default = "qwen2.5-coder:7b-base-q6_K",
            },
            num_ctx = {
              default = 16384,
            },
          },
        })
      end,
      openai = function()
        return require("codecompanion.adapters").extend("openai", {
          env = {
            OPENAI_API_KEY = os.getenv("OPENAI_API_KEY"),
          },
          schema = {
            model = {
              default = "gpt-4.1-mini",
            },
            temperature = {
              default = 0,
            },
            max_tokens = {
              default = 16384,
            },
          },
        })
      end,
      gemini = function()
        return require("codecompanion.adapters").extend("gemini", {
          env = {
            api_key = os.getenv("GEMINI_API_KEY"),
          },
          opts = {
            vision = true,
          },
          schema = {
            model = {
              default = "gemini-2.0-flash-exp",
            },
          },
        })
      end,
      openrouter = function()
        return require("codecompanion.adapters").extend("openai_compatible", {
          env = {
            url = "https://openrouter.ai/api",
            api_key = "OPENROUTER_API_KEY",
            chat_url = "/v1/chat/completions",
          },
          schema = {
            model = {
              default = "qwen/qwen-2.5-coder-32b-instruct:free",
            },
          },
        })
      end,
    },
    acp = {
      gemini_cli = function()
        return require("codecompanion.adapters").extend("gemini_cli", {
          defaults = {
            auth_method = "oauth-personal", -- Uses your Google login / Gemini Pro subscription
          },
          opts = {
            vision = true,
          },
        })
      end,
      opencode = function()
        return require("codecompanion.adapters").extend("opencode", {
          defaults = {
            model = "opencode",
          },
          opts = {
            vision = false,
          },
        })
      end,
    },
  },
  prompt_library = require("config.codecompanion.prompt_library").library,
})

local function patch_history_config()
  -- If history extension exists, ensure title generation uses HTTP adapter (not ACP)
  if _G.codecompanion_config.extensions and _G.codecompanion_config.extensions.history then
    if _G.codecompanion_config.extensions.history.opts then
      -- Set title_generation_opts to use HTTP adapter since ACP doesn't support it
      _G.codecompanion_config.extensions.history.opts.title_generation_opts = {
        adapter = "gemini",
        model = "gemini-2.5-flash",
        refresh_every_n_prompts = 0,
        max_refreshes = 3,
      }
    end
  end
end

patch_history_config()

-- Load saved preference on startup
local saved_adapter, saved_model = load_model_preference()
if saved_adapter and saved_model then
  apply_model_config(saved_adapter, saved_model)
end

-- Setup with enhanced spinner integration
local spinner = require("spinner")
local group = vim.api.nvim_create_augroup("CodeCompanionHooks", {})

vim.api.nvim_create_autocmd({ "User" }, {
  pattern = "CodeCompanionRequest*",
  group = group,
  callback = function(request)
    if request.match == "CodeCompanionRequestStarted" then
      spinner.show()
      vim.notify("🤖 Processing request...", vim.log.levels.INFO, { timeout = 1000 })
    elseif request.match == "CodeCompanionRequestFinished" then
      spinner.hide()
    end
  end,
})

-- Enhanced buffer management - Disable Supermaven in AI chat
local function is_codecompanion_buffer(bufnr)
  local ft = vim.api.nvim_buf_get_option(bufnr, "filetype")
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  return ft == "codecompanion"
    or bufname:match("codecompanion")
    or bufname:match("CodeCompanion")
end

local codecompanion_group = vim.api.nvim_create_augroup("CodeCompanionSupermaven", { clear = true })

vim.api.nvim_create_autocmd({ "BufEnter", "FileType" }, {
  group = codecompanion_group,
  callback = function(args)
    if is_codecompanion_buffer(args.buf) then
      vim.cmd("silent! SupermavenStop")
    end
  end,
})

vim.api.nvim_create_autocmd("BufLeave", {
  group = codecompanion_group,
  callback = function(args)
    if is_codecompanion_buffer(args.buf) then
      -- Small delay to ensure we're in a normal buffer
      vim.defer_fn(function()
        local current_buf = vim.api.nvim_get_current_buf()
        if not is_codecompanion_buffer(current_buf) then
          vim.cmd("silent! SupermavenRestart")
        end
      end, 100)
    end
  end,
})

require("codecompanion").setup(_G.codecompanion_config)

-- Patch: fix ACP apply_default_model substring matching picking wrong model
-- (e.g. "MiniMax-M2.5-highspeed" matching before "MiniMax-M2.5")
do
  local Connection = require("codecompanion.acp")
  if Connection and Connection.apply_default_model then
    local original = Connection.apply_default_model
    Connection.apply_default_model = function(self)
      -- Filter out highspeed models from available list before matching
      if self._models and self._models.availableModels then
        local filtered = {}
        for _, model in ipairs(self._models.availableModels) do
          if not model.modelId:find("%-highspeed$") then
            table.insert(filtered, model)
          end
        end
        self._models.availableModels = filtered
      end
      return original(self)
    end
  end
end
