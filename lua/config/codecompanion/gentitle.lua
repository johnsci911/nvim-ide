-- Custom slash command for generating chat titles
-- Works with any adapter including ACP

local M = {}

---Generate a title for the current chat buffer
function M.generate_title_for_current_chat()
  local codecompanion = require("codecompanion")
  local buf = vim.api.nvim_get_current_buf()
  
  -- Get the chat object
  local chat = codecompanion.buf_get_chat(buf)
  if not chat then
    vim.notify("No active chat buffer", vim.log.levels.WARN)
    return
  end
  
  -- Get messages
  local messages = {}
  if chat.messages then
    for _, msg in ipairs(chat.messages) do
      if msg.role == "user" and msg.content then
        table.insert(messages, msg)
      end
    end
  end
  
  if #messages == 0 then
    vim.notify("No messages in chat to generate title from", vim.log.levels.WARN)
    return
  end
  
  -- Use first user message as fallback title
  local first_msg = messages[1].content
  local fallback_title = first_msg:match("^[^\n]+"):sub(1, 50)
  if #first_msg > 50 then
    fallback_title = fallback_title .. "..."
  end
  
  -- Try using OpenCode CLI to generate a better title
  local handle = io.popen("opencode -t --model minimax/MiniMax-M2.5 2>/dev/null << 'EOF'\nGenerate a short title (max 40 chars) for this conversation. Just return the title.\n\n" .. first_msg:sub(1, 300) .. "\nEOF\n")
  
  local title = fallback_title
  if handle then
    local result = handle:read("*a"):gsub("^%s+", ""):gsub("%s+$", "")
    handle:close()
    if result and #result > 3 and #result < 45 then
      title = result
    end
  end
  
  -- Update buffer title
  local ok, err = pcall(function()
    if chat.opts and chat.opts.buf_name then
      local new_name = "CodeCompanion: " .. title
      vim.api.nvim_buf_set_name(buf, new_name)
    end
  end)
  
  if not ok then
    -- Fallback: just notify the title
    vim.notify("Title: " .. title, vim.log.levels.INFO)
  else
    vim.notify("Title generated: " .. title, vim.log.levels.INFO)
  end
end

---Create a slash command for generating titles
M.slash_command = {
  name = "gentitle",
  description = "Generate a title for this chat",
  callback = function(chat)
    M.generate_title_for_current_chat()
  end,
}

return M
