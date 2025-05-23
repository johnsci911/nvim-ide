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

vim.api.nvim_create_user_command("CCSwitchModel", switch_model, {})

-- Save config globally to allow dynamic edits
_G.codecompanion_config = {
  display = {
    chat = {
      intro_message = "Welcome! Ask away✨! Press ? for options",
      show_header_separator = true,
      separator = "─",
      show_references = true,
      show_settings = true,
      show_token_count = true,
      start_in_insert_mode = true,
      auto_scroll = true,
      opts = {
        ---Decorate the user message before it's sent to the LLM
        ---@param message string
        ---@param adapter CodeCompanion.Adapter
        ---@param context table
        ---@return string
        prompt_decorator = function(message, adapter, context)
          return string.format([[<prompt>%s</prompt>]], message)
        end,
      },
      icons = {
        pinned_buffer = " ",
        watched_buffer = "👀 ",
      },
      debug_window = {
        width = vim.o.columns - 5,
        height = vim.o.lines - 2,
      },
      window = {
        layout = "vertical",
        position = nil,
        border = "single",
        height = 0.8,
        width = 0.45,
        relative = "editor",
        full_height = true,
        opts = {
          breakindent = true,
          cursorcolumn = false,
          cursorline = false,
          foldcolumn = "0",
          linebreak = true,
          list = false,
          numberwidth = 2,
          signcolumn = "no",
          spell = false,
          wrap = true,
        },
      },
      tools = {
        ["cmd_runnder"] = {
          opts = {
            requires_approval = true,
          }
        },
      },
      token_count = function(tokens)
        return " (" .. tokens .. " tokens)"
      end,
    },
    roles = {
      ---The header name for the LLM's messages
      ---@type string|fun(adapter: CodeCompanion.Adapter): string
      llm = function(adapter)
        return "CodeCompanion (" .. adapter.formatted_name .. ")"
      end,

      ---The header name for your messages
      ---@type string
      user = "Me",
    },
    diff = {
      enabled = true,
      close_chat_at = 240,  -- Close an open chat buffer if the total columns of your display are less than...
      layout = "vertical",  -- vertical|horizontal split for default provider
      opts = { "internal", "filler", "closeoff", "algorithm:patience", "followwrap", "linematch:120" },
      provider = "default", -- default|mini_diff
    },
  },
  extensions = {
    vectorcode = {
      opts = {
        add_tool = true,
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
            default = models.ollama[1] or "qwen2.5-coder:7b",
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
  prompt_library = {
    ["Docusaurus"] = {
      strategy = "chat",
      description = "Write documentation for me",
      opts = {
        index = 11,
        is_slash_cmd = false,
        auto_submit = false,
        short_name = "docs",
      },
      references = {
        {
          type = "file",
          path = {
            "doc/.vitepress/config.mjs",
            "lua/codecompanion/config.lua",
            "README.md",
          },
        },
      },
      prompts = {
        {
          role = "user",
          content =
          [[I'm rewriting the documentation for my plugin CodeCompanion.nvim, as I'm moving to a vitepress website. Can you help me rewrite it?

I'm sharing my vitepress config file so you have the context of how the documentation website is structured in the `sidebar` section of that file.

I'm also sharing my `config.lua` file which I'm mapping to the `configuration` section of the sidebar.
]],
        },
      },
    },
  },
}

-- Set up CodeCompanion with the initial config
codecompanion.setup(_G.codecompanion_config)
