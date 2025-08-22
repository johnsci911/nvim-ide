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
    "qwen/qwen-2.5-coder-32b-instruct:free",
    "qwen/qwen3-coder:free",
  },
}

-- Fallback models
if #models.ollama == 0 then
  models.ollama = { "qwen2.5-coder:7b-base-q6_K", "GandalfBaum/llama3.2-claude3.7:latest" }
end

-- Initialize global config early to avoid undefined references
_G.codecompanion_config = {
  strategies = { chat = { adapter = "openai" } },
  adapters = {},
}

-- Helper functions (defined early to avoid reference errors)
local function get_current_adapter()
  return _G.codecompanion_config.strategies.chat.adapter or "openai"
end

local function get_current_model_name()
  local adapter_name = get_current_adapter()
  local adapter_fn = _G.codecompanion_config.adapters[adapter_name]
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
  local adapters = _G.codecompanion_config.adapters
  local adapter_fn = adapters[adapter_name]
  if adapter_fn then
    local adapter = adapter_fn()
    if adapter.schema and adapter.schema.model then
      adapter.schema.model.default = model_name
    end
    if adapter_name == "openrouter" then
      adapter.env.api_key = os.getenv("OPENROUTER_API_KEY")
    end
    -- Update the adapter function to return this updated adapter
    adapters[adapter_name] = function()
      return adapter
    end
  else
    -- fallback: define adapter function as before
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

  -- Update all strategies
  for _, strategy in pairs(_G.codecompanion_config.strategies) do
    strategy.adapter = adapter_name
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

  vim.ui.select(available_adapters, {
    prompt = "🤖 Select AI Provider:",
    format_item = function(item)
      local adapter = item:gsub(" %(current%)", "")
      local icon = adapter == "openai" and "🚀" or adapter == "anthropic" and "💡" or adapter == "ollama" and "🐑" or "💻"
      return icon .. " " .. adapter:gsub("^%l", string.upper)
    end
  }, function(selection)
    if not selection then return end

    local adapter_name = selection:match("^[^%s]+"):gsub(" %(current%)", "")
    local available_models = models[adapter_name]

    vim.ui.select(available_models, {
      prompt = "Select model for " .. adapter_name:gsub("^%l", string.upper) .. ":",
      format_item = function(model)
        local current = get_current_model_name()
        return model == current and "✓ " .. model or "  " .. model
      end
    }, function(choice)
      if not choice then return end

      apply_model_config(adapter_name, choice)
      save_model_preference(adapter_name, choice)

      vim.notify("✨ Switched to " .. adapter_name:gsub("^%l", string.upper) .. ": " .. choice, vim.log.levels.INFO)
    end)
  end)
end

-- Quick model switching functions
local function quick_switch_to_gpt4()
  apply_model_config("openai", "gpt-4.1 mini")
  save_model_preference("openai", "gpt-4.1 mini")
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
_G.codecompanion_config = {
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
        keymap = "gh",
        save_chat_keymap = "sc",
        auto_save = true,
        expiration_days = 0,
        picker = "telescope",
        auto_generate_title = true,
        title_generation_opts = { adapter = nil, model = nil },
        continue_last_chat = false,
        delete_on_clearing_chat = false,
        dir_to_save = vim.fn.stdpath("data") .. "/codecompanion-history",
        enable_logging = false,
      },
    },
  },
  strategies = {
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
  prompt_library = {
    ["Generate a Commit Message"] = {
      prompts = {
        {
          role = "user",
          content = function()
            return
                "Write commit message with commitizen convention. Write clear, informative commit messages that explain the 'what' and 'why' behind changes, not just the 'how'."
                .. "\n\n```\n"
                .. vim.fn.system("git diff")
                .. "\n```"
          end,
          opts = {
            contains_code = true,
          },
        },
      },
    },
    ["Explain"] = {
      strategy = "chat",
      description = "Explain how code in a buffer works",
      opts = {
        default_prompt = true,
        modes = { "v" },
        short_name = "explain",
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
      strategy = "chat",
      description = "Explain how code works",
      opts = {
        short_name = "explain-code",
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
      strategy = "chat",
      description = "Generate a commit message for staged change",
      opts = {
        short_name = "staged-commit",
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
      strategy = "inline",
      description = "Add documentation for code.",
      opts = {
        modes = { "v" },
        short_name = "inline-doc",
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
      strategy = "chat",
      description = "Write documentation for code.",
      opts = {
        modes = { "v" },
        short_name = "doc",
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
      strategy = "chat",
      description = "Review the provided code snippet.",
      opts = {
        modes = { "v" },
        short_name = "review",
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
      strategy = "chat",
      description = "Review code and provide suggestions for improvement.",
      opts = {
        short_name = "review-code",
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
      strategy = "inline",
      description = "Refactor the provided code snippet.",
      opts = {
        modes = { "v" },
        short_name = "refactor",
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
      strategy = "chat",
      description = "Refactor the provided code snippet.",
      opts = {
        short_name = "refactor-code",
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
      strategy = "inline",
      description = "Give better naming for the provided code snippet.",
      opts = {
        modes = { "v" },
        short_name = "naming",
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
      strategy = "chat",
      description = "Give better naming for the provided code snippet.",
      opts = {
        short_name = "better-naming",
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
}

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
