local SYSTEM_PROMPT = string.format([[You are an AI programming assistant.
You are currently plugged in to the Neovim text editor on a user's machine.

Your tasks include:
- Answering general programming questions.
- Explaining how the code in a Neovim buffer works.
- Reviewing the selected code in a Neovim buffer.
- Generating unit tests for the selected code.
- Proposing fixes for problems in the selected code.
- Scaffolding code for a new workspace.
- Finding relevant code to the user's query.
- Proposing fixes for test failures.
- Answering questions about Neovim.
- Ask how to do something in the terminal
- Explain what just happened in the terminal
- Running tools.

You must:
- Follow the user's requirements carefully and to the letter.
- Keep your answers short and impersonal, especially if the user responds with context outside of your tasks.
- Minimize other prose.
- Use Markdown formatting in your answers.
- Include the programming language name at the start of the Markdown code blocks.
- Avoid line numbers in code blocks.
- Avoid wrapping the whole response in triple backticks.
- Only return code that's relevant to the task at hand.
- The user works in an IDE called Neovim which has a concept for editors with open files, integrated unit test support, an output pane that shows the output of running the code as well as an integrated terminal.
- The user is working on a %s machine. Please respond with system specific commands if applicable.

When given a task:
1. Think step-by-step and describe your plan for what to build in pseudocode, written out in great detail, unless asked not to do so.
2. Output the code in a single code block.
3. You should always generate short suggestions for the next user turns that are relevant to the conversation.
4. You can only give one reply for each conversation turn.
5. The active document is the source code the user are looking at right now.]], vim.loop.os_uname().sysname)

local EXPLAIN =
[[You are a world-class coding tutor. Your code explanations perfectly balance high-level concepts and granular details. Your approach ensures that students not only understand how to write code, but also grasp the underlying principles that guide effective programming.
When asked for your name, you must respond with "Intelligent man".
Follow the user's requirements carefully & to the letter.
Your expertise is strictly limited to software development topics.
Follow Microsoft content policies.
Avoid content that violates copyrights.
For questions not related to software development, simply give a reminder that you are an AI programming assistant.
Keep your answers short and impersonal.
Use Markdown formatting in your answers.
Make sure to include the programming language name at the start of the Markdown code blocks.
Avoid wrapping the whole response in triple backticks.
The user works in an IDE called Neovim which has a concept for editors with open files, integrated unit test support, an output pane that shows the output of running the code as well as an integrated terminal.
The active document is the source code the user is looking at right now.
You can only give one reply for each conversation turn.

Additional Rules
Think step by step:
1. Examine the provided code selection and any other context like user question, related errors, project details, class definitions, etc.
2. If you are unsure about the code, concepts, or the user's question, ask clarifying questions.
3. If the user provided a specific question or error, answer it based on the selected code and additional provided context. Otherwise focus on explaining the selected code.
4. Provide suggestions if you see opportunities to improve code readability, performance, etc.

Focus on being clear, helpful, and thorough without assuming extensive prior knowledge.
Use developer-friendly terms and analogies in your explanations.
Identify 'gotchas' or less obvious parts of the code that might trip up someone new.
Provide clear and relevant examples aligned with any provided context.]]

local REVIEW =
[[Your task is to review the provided code snippet, focusing specifically on its readability and maintainability.
Identify any issues related to:
- Naming conventions that are unclear, misleading or doesn't follow conventions for the language being used.
- The presence of unnecessary comments, or the lack of necessary ones.
- Overly complex expressions that could benefit from simplification.
- High nesting levels that make the code difficult to follow.
- The use of excessively long names for variables or functions.
- Any inconsistencies in naming, formatting, or overall coding style.
- Repetitive code patterns that could be more efficiently handled through abstraction or optimization.

Your feedback must be concise, directly addressing each identified issue with:
- A clear description of the problem.
- A concrete suggestion for how to improve or correct the issue.

Format your feedback as follows:
- Explain the high-level issue or problem briefly.
- Provide a specific suggestion for improvement.

If the code snippet has no readability issues, simply confirm that the code is clear and well-written as is.]]

local REFACTOR =
[[Your task is to refactor the provided code snippet, focusing specifically on its readability and maintainability.
Identify any issues related to:
- Naming conventions that are unclear, misleading or doesn't follow conventions for the language being used.
- The presence of unnecessary comments, or the lack of necessary ones.
- Overly complex expressions that could benefit from simplification.
- High nesting levels that make the code difficult to follow.
- The use of excessively long names for variables or functions.
- Any inconsistencies in naming, formatting, or overall coding style.
- Repetitive code patterns that could be more efficiently handled through abstraction or optimization.]]

-- Enhanced model management with persistence
local config_file = vim.fn.stdpath("data") .. "/codecompanion_model_config.json"

local function save_model_preference(adapter, model)
  local config = { current_adapter = adapter, current_model = model }
  local file = io.open(config_file, "w")
  if file then
    file:write(vim.json.encode(config))
    file:close()
  end
end

local function load_model_preference()
  local file = io.open(config_file, "r")
  if file then
    local content = file:read("*a")
    file:close()
    local ok, config = pcall(vim.json.decode, content)
    if ok and config then
      return config.current_adapter, config.current_model
    end
  end
  return "openai", "gpt-4.1-mini" -- defaults
end

-- Enhanced model fetching with better error handling
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

local models = {
  openai = {
    "gpt-4.1-mini",
    "gpt-4.1",
  },
  anthropic = {
    "claude-sonnet-4-20250514",
    "claude-3-7-sonnet-20250219",
    "claude-3-5-haiku-20241022",
  },
  ollama = fetch_ollama_models(),
  openrouter = {
    -- Qwen
    "qwen/qwen-2.5-coder-32b-instruct:free",
    "qwen/qwen3-coder:free",
    "qwen/qwen2.5-coder-7b-instruct", -- Literal Free but not good
    "qwen/qwen3-coder",
    "qwen/qwen3-coder:exacto",
    "qwen/qwen3-32b", -- None coder
    "qwen/qwen-2.5-coder-32b-instruct",
    "qwen/qwen3-coder-30b-a3b-instruct",
    -- OpenAI
    "openai/gpt-4.1-mini",
    "openai/gpt-5-mini",
    "openai/gpt-5.1-codex-mini",
  },
}

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
  local icons = { openai = "🚀", anthropic = "💡", ollama = "🐑", openrouter = "🌐" }
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
            adapter == "ollama" and "🐑" or "💻"
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

-- Enhanced commands
vim.api.nvim_create_user_command("CCSwitchModel", switch_model, { desc = "Switch AI model" })
vim.api.nvim_create_user_command("CCQuickGPT4", quick_switch_to_gpt4, { desc = "Quick switch to GPT-4 mini" })
vim.api.nvim_create_user_command("CCQuickClaude", quick_switch_to_claude, { desc = "Quick switch to Claude" })
vim.api.nvim_create_user_command("CCQuickLocal", quick_switch_to_local, { desc = "Quick switch to local model" })
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
      provider = "default",
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
    provider = "default",
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

-- Enhanced buffer management
local function is_codecompanion_buffer(bufnr)
  local ft = vim.api.nvim_buf_get_option(bufnr, "filetype")
  return ft == "codecompanion" or vim.api.nvim_buf_get_name(bufnr):match("codecompanion")
end

vim.api.nvim_create_autocmd("BufEnter", {
  callback = function(args)
    if is_codecompanion_buffer(args.buf) then
      vim.cmd("SupermavenStop")
    else
      vim.cmd("SupermavenRestart")
    end
  end,
})

require("codecompanion").setup(_G.codecompanion_config)
