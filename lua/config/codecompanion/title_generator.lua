-- Custom title generator for CodeCompanion History
-- Works with ACP adapters (like OpenCode) since it uses OpenCode CLI directly

local M = {}

-- Generate a title from chat messages using OpenCode CLI
function M.generate_title_with_opencode(messages)
  if not messages or #messages == 0 then
    return nil
  end

  -- Extract user messages to build context
  local context = {}
  local max_messages = 6 -- Use last 6 messages for context
  
  local start_idx = math.max(1, #messages - max_messages + 1)
  for i = start_idx, #messages do
    local msg = messages[i]
    if msg.role == "user" and msg.content then
      local content = msg.content
      -- Truncate long messages
      if #content > 500 then
        content = content:sub(1, 500) .. "..."
      end
      table.insert(context, content)
    end
  end

  if #context == 0 then
    return nil
  end

  local prompt = string.format([[
Generate a short, descriptive title (max 50 characters) for this conversation.
The title should summarize what the user is working on or asking about.

Recent conversation:
%s

Respond with ONLY the title, no quotes or explanation.
]], table.concat(context, "\n\n"))

  -- Use opencode CLI to generate title
  local tmpfile = vim.fn.tempname()
  local cmd = string.format(
    'echo %s | opencode -t --model minimax/MiniMax-M2.5 2>/dev/null > %s || echo ""',
    vim.fn.shellescape(prompt),
    tmpfile
  )

  vim.fn.system(cmd)
  
  local file = io.open(tmpfile, "r")
  local title = nil
  if file then
    title = file:read("*a"):gsub("^%s+", ""):gsub("%s+$", ""):gsub("\n", " ")
    file:close()
  end
  vim.fn.delete(tmpfile)

  -- Validate title
  if title and #title > 3 and #title < 60 then
    return title
  end

  return nil
end

-- Fallback title from first user message
function M.generate_fallback_title(messages)
  if not messages or #messages == 0 then
    return "New Chat"
  end

  -- Find first user message
  for _, msg in ipairs(messages) do
    if msg.role == "user" and msg.content then
      local content = msg.content
      -- Take first line or first 50 chars
      local first_line = content:match("^[^\n]+")
      if first_line then
        local title = first_line:sub(1, 50)
        if #content > 50 then
          title = title .. "..."
        end
        return title
      end
    end
  end

  return "New Chat"
end

-- Register custom title generation hook
-- This will be called by the history extension
function M.setup()
  -- The history extension will use the adapter specified in title_generation_opts
  -- But we can also hook into it manually if needed
  
  -- Create an autocmd to generate titles for ACP chats
  local group = vim.api.nvim_create_augroup("CodeCompanionCustomTitle", { clear = true })
  
  vim.api.nvim_create_autocmd({ "User" }, {
    pattern = "CodeCompanionChatSubmitted",
    group = group,
    callback = function(args)
      -- This is a fallback - the history extension should handle it
      -- But we can add additional logic here if needed
    end,
  })
end

return M
