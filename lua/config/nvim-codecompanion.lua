local codecompanion = require("codecompanion")

local models = {
  ollama = {
    "qwen2.5-coder:7b",
    "GandalfBaum/llama3.2-claude3.7:latest",
  },
  openai = {
    "gpt-4.1-mini",
  },
}

local function switch_model()
  local adapter_name = "ollama"
  local available_models = models[adapter_name]
  if not available_models then
    print("No models configured for adapter: " .. adapter_name)
    return
  end

  vim.ui.select(available_models, {
    prompt = "Select model for " .. adapter_name,
  }, function(choice)
    if choice then
      -- Update the adapter schema default model
      local adapters = require("codecompanion.adapters")
      local adapter = adapters[adapter_name]
      if adapter and adapter.schema and adapter.schema.model then
        adapter.schema.model.default = choice
        print("Switched " .. adapter_name .. " model to: " .. choice)
      else
        print("Failed to update model for adapter: " .. adapter_name)
      end
    else
      print("Model selection cancelled")
    end
  end)
end

vim.api.nvim_create_user_command("CCSwitchModel", switch_model, {})

-- Keybinding example (commented out, enable when needed)
-- { "<leader>cm",    '<Cmd>CCSwitchModel<CR>',                                    desc = 'Switch CodeCompanion Model' },

require("codecompanion").setup({
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
      token_count = function(tokens)
        return " (" .. tokens .. " tokens)"
      end,
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
            -- default = "GandalfBaum/llama3.2-claude3.7:latest",
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
})

