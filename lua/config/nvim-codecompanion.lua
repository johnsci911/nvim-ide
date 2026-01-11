-- Load modules
local prompts = require("config.codecompanion.prompts")
local models_module = require("config.codecompanion.models")

-- Use prompts from module
local SYSTEM_PROMPT = prompts.SYSTEM_PROMPT
local EXPLAIN = prompts.EXPLAIN
local REVIEW = prompts.REVIEW
local REFACTOR = prompts.REFACTOR

-- Use models from module
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

-- Helper functions (defined early to avoid reference errors)
local function get_current_adapter()
  return _G.codecompanion_config.interactions.chat.adapter or "openai"
end

local function get_current_model_name()
  local adapter_name = get_current_adapter()
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
  local icons = { openai = "🚀", anthropic = "💡", gemini = "✨", ollama = "🐑", openrouter = "🌐" }
  return (icons[adapter] or "🤖") .. " " .. model
end

local function apply_model_config(adapter_name, model_name)
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

  -- Update allinteractions
  for _, interaction in pairs(_G.codecompanion_config.interactions) do
    interaction.adapter = adapter_name
  end

  _G.codecompanion_config.display.chat.intro_message = "✨ Using " ..
      adapter_name:gsub("^%l", string.upper) .. ": " .. model_name .. ". Press ? for options ✨"

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
    prompt_title = "🤖 AI Providers",
    layout_config = {
      width = 0.3,
      height = 0.3
    },
    finder = require('telescope.finders').new_table({
      results = available_adapters,
      entry_maker = function(entry)
        local adapter = entry:gsub(" %(current%)", "")
        local icon = adapter == "openai" and "🚀" or
            adapter == "anthropic" and "💡" or
            adapter == "gemini" and "✨" or
            adapter == "ollama" and "🐑" or
            adapter == "openrouter" and "🌐" or "💻"
        return {
          value = entry,
          display = icon .. " " .. adapter:gsub("^%l", string.upper),
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

        require('telescope.pickers').new({}, {
          prompt_title = "Models: " .. adapter_name:gsub("^%l", string.upper),
          layout_config = {
            width = 0.3,
            height = 0.3
          },
          finder = require('telescope.finders').new_table({
            results = available_models,
            entry_maker = function(model)
              local current = get_current_model_name()
              return {
                value = model,
                display = model == current and "✓ " .. model or "  " .. model,
                ordinal = model
              }
            end
          }),
          sorter = require('telescope.sorters').get_generic_fuzzy_sorter(),
          attach_mappings = function(model_prompt_bufnr, model_map)
            model_map('i', '<CR>', function()
              local model_selection = require('telescope.actions.state').get_selected_entry()
              require('telescope.actions').close(model_prompt_bufnr)

              apply_model_config(adapter_name, model_selection.value)
              save_model_preference(adapter_name, model_selection.value)

              vim.notify("✨ Switched to " .. adapter_name:gsub("^%l", string.upper) .. ": " .. model_selection.value,
                vim.log.levels.INFO)
            end)
            return true
          end
        }):find()
      end)
      return true
    end
  }):find()
end

local function get_git_diff()
  local output = vim.fn.system("git diff")
  if type(output) == "table" then
    -- If it's a table, join it with newlines
    return table.concat(output, "\n")
  end
  return output
end

local function get_git_staged_diff()
  local output = vim.fn.system("git diff --staged")
  if type(output) == "table" then
    -- If it's a table, join it with newlines
    return table.concat(output, "\n")
  end
  return output
end

-- Quick model switching functions
local function quick_switch_to_gpt4()
  apply_model_config("openai", "gpt-4.1-mini")
  save_model_preference("openai", "gpt-4.1-mini")
  vim.notify("⚡ Quick switch to GPT-4", vim.log.levels.INFO)
end

local function quick_switch_to_claude()
  apply_model_config("anthropic", "claude-3-5-sonnet-20241022")
  save_model_preference("anthropic", "claude-3-5-sonnet-20241022")
  vim.notify("⚡ Quick switch to Claude", vim.log.levels.INFO)
end

local function quick_switch_to_local()
  local model = models.ollama[1] or "qwen2.5-coder:7b-base-q6_K"
  apply_model_config("ollama", model)
  save_model_preference("ollama", model)
  vim.notify("⚡ Quick switch to Local: " .. model, vim.log.levels.INFO)
end

local function quick_switch_to_gemini()
  apply_model_config("gemini", "gemini-2.0-flash-exp")
  save_model_preference("gemini", "gemini-2.0-flash-exp")
  vim.notify("⚡ Quick switch to Gemini", vim.log.levels.INFO)
end

local function quick_switch_to_openrouter()
  apply_model_config("openrouter", "qwen/qwen-2.5-coder-32b-instruct:free")
  save_model_preference("openrouter", "qwen/qwen-2.5-coder-32b-instruct:free")
  vim.notify("⚡ Quick switch to OpenRouter", vim.log.levels.INFO)
end

-- Enhanced commands
vim.api.nvim_create_user_command("CCSwitchModel", switch_model, { desc = "Switch AI model" })
vim.api.nvim_create_user_command("CCQuickGPT4", quick_switch_to_gpt4, { desc = "Quick switch to GPT-4 mini" })
vim.api.nvim_create_user_command("CCQuickClaude", quick_switch_to_claude, { desc = "Quick switch to Claude" })
vim.api.nvim_create_user_command("CCQuickGemini", quick_switch_to_gemini, { desc = "Quick switch to Gemini" })
vim.api.nvim_create_user_command("CCQuickLocal", quick_switch_to_local, { desc = "Quick switch to local model" })
vim.api.nvim_create_user_command("CCQuickOpenRouter", quick_switch_to_openrouter, { desc = "Quick switch to OpenRouter" })
vim.api.nvim_create_user_command("CCCurrentModel", function()
  vim.notify("Current model: " .. get_current_model(), vim.log.levels.INFO)
end, { desc = "Show current model" })

-- Enhanced keymaps (add these to your main keymap file)
-- vim.keymap.set("n", "<leader>cs", switch_model, { desc = "Switch AI model" })
-- vim.keymap.set("n", "<leader>c4", quick_switch_to_gpt4, { desc = "Quick GPT-4" })
-- vim.keymap.set("n", "<leader>cc", quick_switch_to_claude, { desc = "Quick Claude" })
-- vim.keymap.set("n", "<leader>cl", quick_switch_to_local, { desc = "Quick Local" })

-- Statusline integration function (for your statusline plugin)
_G.get_codecompanion_status = function()
  return get_current_model()
end

-- Complete config
_G.codecompanion_config = vim.tbl_deep_extend("force", _G.codecompanion_config, {
  opts = { system_prompt = SYSTEM_PROMPT },
  display = {
    diff = {
      enabled = true,
      close_chat_at = 240,
      layout = "vertical",
      opts = { "internal", "filler", "closeoff", "algorithm:patience", "followwrap", "linematch:120" },
      provider = "mini_diff",
    },
    chat = {
      intro_message = "✨ Using OpenAI: gpt-4.1-mini. Press ? for options ✨",
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
        auto_generate_title = true,
        title_generation_opts = {
          ---Adapter for generating titles (defaults to current chat adapter)
          adapter = nil,               -- "copilot"
          ---Model for generating titles (defaults to current chat model)
          model = nil,                 -- "gpt-4o"
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
  },
  prompt_library = {
    ["Generate a Commit Message"] = {
      prompts = {
        {
          role = "user",
          content = function()
            return
                "Write commit message with commitizen convention. Write clear, informative commit messages that explain the 'what' and 'why' behind changes, not just the 'how'."
                .. "\n\n```\n"
                .. get_git_diff()
                .. "\n```"
          end,
          opts = {
            contains_code = true,
          },
        },
      },
    },
    ["Generate a Commit Message for Staged"] = {
      interaction = "chat",
      description = "Generate a commit message for staged change",
      opts = {
        alias = "staged-commit",
        auto_submit = true,
        is_slash_cmd = true,
      },
      prompts = {
        {
          role = "user",
          content = function()
            return
                "Write commit message for the change with commitizen convention. Write clear, informative commit messages that explain the 'what' and 'why' behind changes, not just the 'how'."
                .. "\n\n```\n"
                .. get_git_staged_diff()
                .. "\n```"
          end,
          opts = {
            contains_code = true,
          },
        },
      }
    },
    ["Explain"] = {
      interaction = "chat",
      description = "Explain how code in a buffer works",
      opts = {
        default_prompt = true,
        modes = { "v" },
        alias = "explain",
        auto_submit = true,
        user_prompt = false,
        stop_context_insertion = true,
      },
      prompts = {
        {
          role = "system",
          content = EXPLAIN,
          opts = {
            visible = false,
          },
        },
        {
          role = "user",
          content = function(context)
            local code = require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)

            return "Please explain how the following code works:\n\n```"
                .. context.filetype
                .. "\n"
                .. code
                .. "\n```\n\n"
          end,
          opts = {
            contains_code = true,
          },
        },
      },
    },
    ["Explain Code"] = {
      interaction = "chat",
      description = "Explain how code works",
      opts = {
        alias = "explain-code",
        auto_submit = false,
        is_slash_cmd = true,
      },
      prompts = {
        {
          role = "system",
          content = EXPLAIN,
          opts = {
            visible = false,
          },
        },
        {
          role = "user",
          content = [[Please explain how the following code works.]],
        },
      },
    },
    ["Generate a Commit Message for Staged"] = {
      interaction = "chat",
      description = "Generate a commit message for staged change",
      opts = {
        alias = "staged-commit",
        auto_submit = true,
        is_slash_cmd = true,
      },
      prompts = {
        {
          role = "user",
          content = function()
            return
                "Write commit message for the change with commitizen convention. Write clear, informative commit messages that explain the 'what' and 'why' behind changes, not just the 'how'."
                .. "\n\n```\n"
                .. vim.fn.system("git diff --staged")
                .. "\n```"
          end,
          opts = {
            contains_code = true,
          },
        },
      },
    },
    ["Inline Document"] = {
      interaction = "inline",
      description = "Add documentation for code.",
      opts = {
        modes = { "v" },
        alias = "inline-doc",
        auto_submit = true,
        user_prompt = false,
        stop_context_insertion = true,
      },
      prompts = {
        {
          role = "user",
          content = function(context)
            local code = require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)

            return
                "Please provide documentation in comment code for the following code and suggest to have better naming to improve readability.\n\n```"
                .. context.filetype
                .. "\n"
                .. code
                .. "\n```\n\n"
          end,
          opts = {
            contains_code = true,
          },
        },
      },
    },
    ["Document"] = {
      interaction = "chat",
      description = "Write documentation for code.",
      opts = {
        modes = { "v" },
        alias = "doc",
        auto_submit = true,
        user_prompt = false,
        stop_context_insertion = true,
      },
      prompts = {
        {
          role = "user",
          content = function(context)
            local code = require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)

            return
                "Please brief how it works and provide documentation in comment code for the following code. Also suggest to have better naming to improve readability.\n\n```"
                .. context.filetype
                .. "\n"
                .. code
                .. "\n```\n\n"
          end,
          opts = {
            contains_code = true,
          },
        },
      },
    },
    ["Review"] = {
      interaction = "chat",
      description = "Review the provided code snippet.",
      opts = {
        modes = { "v" },
        alias = "review",
        auto_submit = true,
        user_prompt = false,
        stop_context_insertion = true,
      },
      prompts = {
        {
          role = "system",
          content = REVIEW,
          opts = {
            visible = false,
          },
        },
        {
          role = "user",
          content = function(context)
            local code = require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)

            return
                "Please review the following code and provide suggestions for improvement then refactor the following code to improve its clarity and readability:\n\n```"
                .. context.filetype
                .. "\n"
                .. code
                .. "\n```\n\n"
          end,
          opts = {
            contains_code = true,
          },
        },
      },
    },
    ["Review Code"] = {
      interaction = "chat",
      description = "Review code and provide suggestions for improvement.",
      opts = {
        alias = "review-code",
        auto_submit = false,
        is_slash_cmd = true,
      },
      prompts = {
        {
          role = "system",
          content = REVIEW,
          opts = {
            visible = false,
          },
        },
        {
          role = "user",
          content =
          "Please review the following code and provide suggestions for improvement then refactor the following code to improve its clarity and readability.",
        },
      },
    },
    ["Refactor"] = {
      interaction = "inline",
      description = "Refactor the provided code snippet.",
      opts = {
        modes = { "v" },
        alias = "refactor",
        auto_submit = true,
        user_prompt = false,
        stop_context_insertion = true,
      },
      prompts = {
        {
          role = "system",
          content = REFACTOR,
          opts = {
            visible = false,
          },
        },
        {
          role = "user",
          content = function(context)
            local code = require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)

            return "Please refactor the following code to improve its clarity and readability:\n\n```"
                .. context.filetype
                .. "\n"
                .. code
                .. "\n```\n\n"
          end,
          opts = {
            contains_code = true,
          },
        },
      },
    },
    ["Refactor Code"] = {
      interaction = "chat",
      description = "Refactor the provided code snippet.",
      opts = {
        alias = "refactor-code",
        auto_submit = false,
        is_slash_cmd = true,
      },
      prompts = {
        {
          role = "system",
          content = REFACTOR,
          opts = {
            visible = false,
          },
        },
        {
          role = "user",
          content = "Please refactor the following code to improve its clarity and readability.",
        },
      },
    },
    ["Naming"] = {
      interaction = "inline",
      description = "Give better naming for the provided code snippet.",
      opts = {
        modes = { "v" },
        alias = "naming",
        auto_submit = true,
        user_prompt = false,
        stop_context_insertion = true,
      },
      prompts = {
        {
          role = "user",
          content = function(context)
            local code = require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)

            return "Please provide better names for the following variables and functions:\n\n```"
                .. context.filetype
                .. "\n"
                .. code
                .. "\n```\n\n"
          end,
          opts = {
            contains_code = true,
          },
        },
      },
    },
    ["Better Naming"] = {
      interaction = "chat",
      description = "Give better naming for the provided code snippet.",
      opts = {
        alias = "better-naming",
        auto_submit = false,
        is_slash_cmd = true,
      },
      prompts = {
        {
          role = "user",
          content = "Please provide better names for the following variables and functions.",
        },
      },
    },
    ["Find and Replace"] = {
      interaction = "inline",
      description = "Find and replace code with confirmation.",
      opts = {
        modes = { "v" },
        alias = "find-replace",
        auto_submit = false,
        user_prompt = true,
        stop_context_insertion = true,
      },
      prompts = {
        {
          role = "user",
          content = function(context)
            local code = require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)

            -- Prompt user for find and replace patterns
            local find_pattern = vim.fn.input("Find pattern: ")
            if find_pattern == "" then
              vim.notify("Find pattern cannot be empty", vim.log.levels.WARN)
              return nil
            end

            local replace_pattern = vim.fn.input("Replace with: ")

            return string.format(
              "In the following code, find all instances of '%s' and replace them with '%s'. Return ONLY the modified code without explanations:\\n\\n```%s\\n%s\\n```",
              find_pattern,
              replace_pattern,
              context.filetype,
              code
            )
          end,
          opts = {
            contains_code = true,
          },
        },
      },
    },
  },
})

local function patch_history_config()
  -- If history extension exists, reset it properly
  if _G.codecompanion_config.extensions and _G.codecompanion_config.extensions.history then
    -- Remove problematic parts
    if _G.codecompanion_config.extensions.history.opts then
      -- Remove title_generation_opts if present
      if _G.codecompanion_config.extensions.history.opts.title_generation_opts then
        _G.codecompanion_config.extensions.history.opts.title_generation_opts = nil
      end
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
