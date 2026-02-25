local M = {}

local prompts = require("config.codecompanion.prompts")
local EXPLAIN = prompts.EXPLAIN
local REVIEW = prompts.REVIEW
local REFACTOR = prompts.REFACTOR
local ACP_MANUAL = prompts.ACP_MANUAL

-- Helper to create code extraction function
local function get_code_fn(start_line, end_line)
  return function(context)
    local code = require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)
    return code
  end
end

-- Helper to create code prompt template
local function code_prompt_template(filetype_var, code_fn)
  return function(context)
    local code = code_fn(context)
    return "```" .. context.filetype .. "\n" .. code .. "\n```\n\n"
  end
end

-- Helper for system prompt wrapper
local function system_prompt(content)
  return {
    role = "system",
    content = content,
    opts = {
      visible = false,
    },
  }
end

-- Helper for user prompt with code
local function user_code_prompt(content_fn, contains_code)
  return {
    role = "user",
    content = content_fn,
    opts = {
      contains_code = contains_code,
    },
  }
end

M.library = {
  -- Explain actions
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
      system_prompt(EXPLAIN),
      user_code_prompt(function(context)
        local code = require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)
        return "Please explain how the following code works:\n\n```" .. context.filetype .. "\n" .. code .. "\n```\n\n"
      end, true),
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
      system_prompt(EXPLAIN),
      { role = "user", content = "Please explain how the following code works.", opts = {} },
    },
  },

  -- Commit message generation
  ["Generate a Commit Message"] = {
    interaction = "chat",
    description = "Generate a commit message",
    opts = {
      alias = "generate-commit",
      auto_submit = true,
      is_slash_cmd = true,
    },
    prompts = {
      user_code_prompt(function()
        return "Write commit message with commitizen convention. Write clear, informative commit messages that explain the 'what' and 'why' behind changes, not just the 'how'."
          .. "\n\n```\n" .. _G.get_git_diff() .. "\n```"
      end, true),
    },
  },

  ["Generate a Commit Message for Staged"] = {
    interaction = "chat",
    description = "Generate a commit message for staged change",
    opts = {
      alias = "generate-commit-staged",
      auto_submit = true,
      is_slash_cmd = true,
    },
    prompts = {
      user_code_prompt(function()
        return "Write commit message for the change with commitizen convention. Write clear, informative commit messages that explain the 'what' and 'why' behind changes, not just the 'how'."
          .. "\n\n```\n" .. _G.get_git_staged_diff() .. "\n```"
      end, true),
    },
  },

  -- Documentation actions
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
      user_code_prompt(function(context)
        local code = require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)
        return "Please provide documentation in comment code for the following code and suggest to have better naming to improve readability.\n\n```" .. context.filetype .. "\n" .. code .. "\n```\n\n"
      end, true),
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
      user_code_prompt(function(context)
        local code = require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)
        return "Please brief how it works and provide documentation in comment code for the following code. Also suggest to have better naming to improve readability.\n\n```" .. context.filetype .. "\n" .. code .. "\n```\n\n"
      end, true),
    },
  },

  -- Review actions
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
      system_prompt(REVIEW),
      user_code_prompt(function(context)
        local code = require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)
        return "Please review the following code and provide suggestions for improvement then refactor the following code to improve its clarity and readability:\n\n```" .. context.filetype .. "\n" .. code .. "\n```\n\n"
      end, true),
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
      system_prompt(REVIEW),
      { role = "user", content = "Please review the following code and provide suggestions for improvement then refactor the following code to improve its clarity and readability.", opts = {} },
    },
  },

  -- Refactor actions
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
      system_prompt(REFACTOR),
      user_code_prompt(function(context)
        local code = require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)
        return "Please refactor the following code to improve its clarity and readability:\n\n```" .. context.filetype .. "\n" .. code .. "\n```\n\n"
      end, true),
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
      system_prompt(REFACTOR),
      { role = "user", content = "Please refactor the following code to improve its clarity and readability.", opts = {} },
    },
  },

  -- Naming actions
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
      user_code_prompt(function(context)
        local code = require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)
        return "Please provide better names for the following variables and functions:\n\n```" .. context.filetype .. "\n" .. code .. "\n```\n\n"
      end, true),
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
      { role = "user", content = "Please provide better names for the following variables and functions.", opts = {} },
    },
  },

  -- Find and Replace
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
      user_code_prompt(function(context)
        local code = require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)
        local find_pattern = vim.fn.input("Find pattern: ")
        if find_pattern == "" then
          vim.notify("Find pattern cannot be empty", vim.log.levels.WARN)
          return nil
        end
        local replace_pattern = vim.fn.input("Replace with: ")
        return string.format(
          "In the following code, find all instances of '%s' and replace them with '%s'. Return ONLY the modified code without explanations:\n\n```%s\n%s\n```",
          find_pattern,
          replace_pattern,
          context.filetype,
          code
        )
      end, true),
    },
  },

  -- Autonomous Code Proposer
  ["Autonomous Code Proposer"] = {
    interaction = "chat",
    description = "Suggest code change with web search, but ask for confirmation before applying.",
    opts = {
      alias = "acp",
      auto_submit = false,
      is_slash_cmd = true,
    },
    prompts = {
      system_prompt(ACP_MANUAL),
      { role = "user", content = "Propose a change to the following code. You can use web search if needed.", opts = {} },
    },
  },
}

return M
