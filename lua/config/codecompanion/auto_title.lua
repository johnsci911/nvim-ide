-- Auto title generator for CodeCompanion
-- Works with ACP adapters (like OpenCode) by using OpenCode CLI directly
-- Automatically generates titles when chat is submitted

local M = {}

local generated_titles = {} -- Track which buffers have already had titles

---Generate a short title from chat messages
local function generate_title(messages)
  if not messages or #messages == 0 then
    return nil
  end

  -- Get first user message
  local first_msg = nil
  for _, msg in ipairs(messages) do
    if msg.role == "user" and msg.content and #msg.content > 0 then
      first_msg = msg.content
      break
    end
  end

  if not first_msg then
    return nil
  end

  -- Extract a short title from the first message
  local title = first_msg:match("^[^\n]+"):gsub("%s+", " "):sub(1, 50)
  
  -- Clean up common prefixes
  title = title:gsub("^[%s%-%*]+", "")
  
  if #title < 3 then
    return nil
  end

  return title .. (#first_msg > 50 and "..." or "")
end

---Apply title to buffer
local function apply_title(bufnr, title)
  if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end
  
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  if bufname:match("^codecompanion:") then
    -- Already has a generated title
    return
  end
  
  local new_name = "codecompanion: " .. title
  vim.api.nvim_buf_set_name(bufnr, new_name)
end

---Auto-generate title for current chat
function M.auto_generate_title()
  local codecompanion = require("codecompanion")
  local bufnr = vim.api.nvim_get_current_buf()
  
  -- Skip if already generated for this buffer
  if generated_titles[bufnr] then
    return
  end
  
  -- Get the chat object
  local chat = codecompanion.buf_get_chat(bufnr)
  if not chat then
    return
  end
  
  -- Get messages
  local messages = {}
  if chat.messages then
    for _, msg in ipairs(chat.messages) do
      table.insert(messages, msg)
    end
  end
  
  if #messages == 0 then
    return
  end
  
  -- Generate title from messages
  local title = generate_title(messages)
  if not title then
    return
  end
  
  -- Mark as processed
  generated_titles[bufnr] = true
  
  -- Apply title
  apply_title(bufnr, title)
  
  vim.schedule(function()
    vim.notify("[AutoTitle] " .. title, vim.log.levels.INFO, { timeout = 1500 })
  end)
end

---Setup autocmds for auto title generation
function M.setup()
  local group = vim.api.nvim_create_augroup("CodeCompanionAutoTitle", { clear = true })
  
  -- Generate title after chat is submitted
  vim.api.nvim_create_autocmd({ "User" }, {
    pattern = "CodeCompanionChatSubmitted",
    group = group,
    callback = function()
      -- Small delay to ensure messages are processed
      vim.defer_fn(function()
        M.auto_generate_title()
      end, 500)
    end,
  })
  
  -- Also try onBufEnter for newly opened chats
  vim.api.nvim_create_autocmd({ "BufEnter" }, {
    pattern = "codecompanion://chat/*",
    group = group,
    callback = function(args)
      vim.defer_fn(function()
        M.auto_generate_title()
      end, 1000)
    end,
  })
end

return M
