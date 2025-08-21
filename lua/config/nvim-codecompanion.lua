local SYSTEM_PROMPT = string.format(
  [[You are an AI programming assistant.
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
- Only return code that's relevant to the task at hand. You may not need to return all of the code that the user has shared.
- The user works in an IDE called Neovim which has a concept for editors with open files, integrated unit test support, an output pane that shows the output of running the code as well as an integrated terminal.
- The user is working on a %s machine. Please respond with system specific commands if applicable.

When given a task:
1. Think step-by-step and describe your plan for what to build in pseudocode, written out in great detail, unless asked not to do so.
2. Output the code in a single code block.
3. You should always generate short suggestions for the next user turns that are relevant to the conversation.
4. You can only give one reply for each conversation turn.
5. The active document is the source code the user is looking at right now.
]],
  vim.loop.os_uname().sysname
)
local EXPLAIN = string.format(
  [[You are a world-class coding tutor. Your code explanations perfectly balance high-level concepts and granular details. Your approach ensures that students not only understand how to write code, but also grasp the underlying principles that guide effective programming.
When asked for your name, you must respond with "Inteligent man".
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
Provide clear and relevant examples aligned with any provided context.
]]
)
local REVIEW = string.format(
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

If the code snippet has no readability issues, simply confirm that the code is clear and well-written as is.
]]
)
local REFACTOR = string.format(
  [[Your task is to refactor the provided code snippet, focusing specifically on its readability and maintainability.
Identify any issues related to:
- Naming conventions that are unclear, misleading or doesn't follow conventions for the language being used.
- The presence of unnecessary comments, or the lack of necessary ones.
- Overly complex expressions that could benefit from simplification.
- High nesting levels that make the code difficult to follow.
- The use of excessively long names for variables or functions.
- Any inconsistencies in naming, formatting, or overall coding style.
- Repetitive code patterns that could be more efficiently handled through abstraction or optimization.
]]
)


local codecompanion = require("codecompanion")

-- Fetch model list from `ollama list` command (plain text parsing)
local function fetch_ollama_models()
  local handle = io.popen("ollama list")
  if not handle then
    print("Failed to run 'ollama list'")
    return {}
  end

  local output = handle:read("*a")
  handle:close()

  local models = {}
  local first_line_skipped = false
  for line in output:gmatch("[^\r\n]+") do
    if first_line_skipped then
      local model = line:match("^(%S+)")
      if model then
        table.insert(models, model)
      end
    else
      first_line_skipped = true -- skip header line
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
}

-- Fallback if no models found for ollama
if #models.ollama == 0 then
  models.ollama = {
    "qwen2.5-coder:7b-base-q6_K",
    "GandalfBaum/llama3.2-claude3.7:latest",
  }
end

-- Switch model and adapter dynamically
local function switch_model()
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

  vim.ui.select(available_adapters, { prompt = "Select AI Model:" }, function(adapter_name)
    if not adapter_name then
      print("Model switch cancelled")
      return
    end

    local available_models = models[adapter_name]
    if not available_models or #available_models == 0 then
      print("No models configured for adapter: " .. adapter_name)
      return
    end

    vim.ui.select(available_models, { prompt = "Select model for " .. adapter_name }, function(choice)
      if not choice then
        print("Model selection cancelled")
        return
      end

      _G.codecompanion_config.adapters[adapter_name] = function()
        local base_env = {}
        if adapter_name == "ollama" then
          base_env = { url = "http://127.0.0.1:11434" }
        elseif adapter_name == "openai" then
          base_env = { OPENAI_API_KEY = os.getenv("OPENAI_API_KEY") }
        elseif adapter_name == "anthropic" then
          base_env = { ANTHROPIC_API_KEY = os.getenv("ANTHROPIC_API_KEY") }
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
      for _, strategy in pairs(_G.codecompanion_config.strategies) do
        strategy.adapter = adapter_name
      end

      local adapter_name_capitalized = adapter_name:gsub("^%l", string.upper)
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
      return "✨ " .. model .. ":"
    end
  end
  return "unknown"
end

vim.api.nvim_create_user_command("CCSwitchModel", switch_model, {})
-- Save config globally to allow dynamic edits
_G.codecompanion_config = {
  opts = {
    system_prompt = SYSTEM_PROMPT,
  },
  display = {
    diff = {
      enabled = true,
      close_chat_at = 240,
      layout = "vertical",
      opts = { "internal", "filler", "closeoff", "algorithm:patience", "followwrap", "linematch:120" },
      provider = "default", -- default|mini_diff
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
  },
  prompt_library = {
    -- Custom the default prompt
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
    -- Add custom prompts
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
      description = "Give betting naming for the provided code snippet.",
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
      description = "Give betting naming for the provided code snippet.",
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

local spinner = require("spinner")
local group = vim.api.nvim_create_augroup("CodeCompanionHooks", {})

vim.api.nvim_create_autocmd({ "User" }, {
  pattern = "CodeCompanionRequest*",
  group = group,
  callback = function(request)
    if request.match == "CodeCompanionRequestStarted" then
      spinner.show()
    elseif request.match == "CodeCompanionRequestFinished" then
      spinner.hide()
    end
  end,
})

local function is_codecompanion_buffer(bufnr)
  local ft = vim.api.nvim_buf_get_option(bufnr, "filetype")
  return ft == "codecompanion" or vim.api.nvim_buf_get_name(bufnr):match("codecompanion")
end

vim.api.nvim_create_autocmd("BufEnter", {
  callback = function(args)
    if is_codecompanion_buffer(args.buf) then
      vim.cmd("SupermavenStop")
      -- print("Supermaven stopped for codecompanion buffer")
    else
      vim.cmd("SupermavenRestart")
      -- print("Supermaven started for non-codecompanion buffer")
    end
  end,
})

codecompanion.setup(_G.codecompanion_config)
