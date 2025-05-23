local codecompanion = require("codecompanion")

-- Function to fetch model list from `ollama list` command (plain text parsing)
local function fetch_ollama_models()
  local models = {}

  local handle = io.popen("ollama list")
  if not handle then
    print("Failed to run 'ollama list'")
    return models
  end

  local output = handle:read("*a")
  handle:close()

  local first_line_skipped = false
  for line in output:gmatch("[^\r\n]+") do
    if not first_line_skipped then
      first_line_skipped = true -- skip header line
    else
      local model = line:match("^(%S+)")
      if model then
        table.insert(models, model)
      end
    end
  end

  return models
end

local models = {
  ollama = fetch_ollama_models(),
  openai = {
    "gpt-4.1-mini",
  },
}

-- Fallback if no models found for ollama
if #models.ollama == 0 then
  models.ollama = {
    "qwen2.5-coder:7b",
    "GandalfBaum/llama3.2-claude3.7:latest",
  }
end

-- Switch model and adapter dynamically
local function switch_model()
  -- Build adapter list dynamically based on available models
  local available_adapters = {}
  for adapter_name, model_list in pairs(models) do
    if model_list and #model_list > 0 then
      table.insert(available_adapters, adapter_name)
    end
  end

  if #available_adapters == 0 then
    print("No adapters with available models found")
    return
  end

  vim.ui.select(available_adapters, {
    prompt = "Select adapter:",
  }, function(adapter_name)
    if not adapter_name then
      print("Model switch cancelled")
      return
    end

    local available_models = models[adapter_name]
    if not available_models or #available_models == 0 then
      print("No models configured for adapter: " .. adapter_name)
      return
    end

    vim.ui.select(available_models, {
      prompt = "Select model for " .. adapter_name,
    }, function(choice)
      if choice then
        -- Update adapter function in config to the chosen model and update strategies
        _G.codecompanion_config.adapters[adapter_name] = function()
          local base_env = {}
          if adapter_name == "ollama" then
            base_env = { url = "http://127.0.0.1:11434" }
          elseif adapter_name == "openai" then
            base_env = { OPENAI_API_KEY = os.getenv("OPENAI_API_KEY") }
          end

          return require("codecompanion.adapters").extend(adapter_name, {
            env = base_env,
            schema = {
              model = { default = choice },
              num_ctx = adapter_name == "ollama" and { default = 16384 } or nil,
              temperature = adapter_name == "openai" and { default = 0 } or nil,
              max_tokens = adapter_name == "openai" and { default = 16384 } or nil,
            },
          })
        end

        -- Update strategies to use the new adapter globally
        _G.codecompanion_config.strategies.chat.adapter = adapter_name
        _G.codecompanion_config.strategies.inline.adapter = adapter_name
        _G.codecompanion_config.strategies.agent.adapter = adapter_name

        -- Capitalized adapter_name
        local adapter_name_capitalized = string.gsub(adapter_name, "^%l", string.upper)

        _G.codecompanion_config.display.chat.intro_message = "  ✨ Using " ..
            adapter_name_capitalized .. ": " .. choice .. ". Press ? for options ✨"

        -- Clear adapter caches
        if codecompanion.adapters_cache then
          codecompanion.adapters_cache[adapter_name] = nil
        end
        if codecompanion.adapters_instances then
          codecompanion.adapters_instances[adapter_name] = nil
        end

        -- Re-setup with updated config
        codecompanion.setup(_G.codecompanion_config)

        print("Switched to adapter '" .. adapter_name .. "' with model '" .. choice .. "'")
      else
        print("Model selection cancelled")
      end
    end)
  end)
end

local function get_current_model()
  local adapter_name = _G.codecompanion_config.strategies.chat.adapter or "ollama"
  local adapter_fn = _G.codecompanion_config.adapters[adapter_name]
  if adapter_fn then
    local adapter = adapter_fn()
    local model = adapter.schema and adapter.schema.model and adapter.schema.model.default
    if model and model ~= "" then
      return "✨ " ..model .. ":"
    end
  end
  return "unknown"
end

vim.api.nvim_create_user_command("CCSwitchModel", switch_model, {})

-- Save config globally to allow dynamic edits
_G.codecompanion_config = {
  display = {
    chat = {
      intro_message = "  ✨ Using Ollama: qwen2.5-coder:7b. Press ? for options ✨",
      show_header_separator = false, -- Show header separators in the chat buffer? Set this to false if you're using an external markdown formatting plugin
      separator = "─", -- The separator between the different messages in the chat buffer
      show_references = true, -- Show references (from slash commands and variables) in the chat buffer?
      show_settings = false, -- Show LLM settings at the top of the chat buffer?
      show_token_count = true, -- Show the token count for each response?
      start_in_insert_mode = false, -- Open the chat buffer in insert mode?
    },
  },
  diff = {
    enabled = true,
    close_chat_at = 240,  -- Close an open chat buffer if the total columns of your display are less than...
    layout = "vertical",  -- vertical|horizontal split for default provider
    opts = { "internal", "filler", "closeoff", "algorithm:patience", "followwrap", "linematch:120" },
    provider = "default", -- default|mini_diff
  },
  extensions = {
    mcphub = {
      callback = "mcphub.extensions.codecompanion",
      opts = {
        make_vars = true,
        make_slash_commands = true,
        show_result_in_chat = true
      }
    },
    history = {
      enabled = true,
      opts = {
        keymap = "gh",
        save_chat_keymap = "sc",
        auto_save = true,
        expiration_days = 0,
        picker = "telescope",
        auto_generate_title = true,
        title_generation_opts = {
          adapter = nil,
          model = nil,
        },
        continue_last_chat = false,
        delete_on_clearing_chat = false,
        dir_to_save = vim.fn.stdpath("data") .. "/codecompanion-history",
        enable_logging = false,
      }
    }
  },
  strategies = {
    chat = {
      adapter = "ollama",
      roles = {
        ---The header name for the LLM's messages
        ---@type string|fun(adapter: CodeCompanion.Adapter): string
        llm = function(adapter)
          return get_current_model()
        end,

        ---The header name for your messages
        ---@type string
        user = "Me:",
      }
    },
    inline = {
      adapter = "ollama",
    },
    agent = {
      adapter = "ollama",
    },
  },
  adapters = {
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
            default = "qwen2.5-coder:7b",
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
  },
}

-- Set up CodeCompanion with the initial config
codecompanion.setup(_G.codecompanion_config)
