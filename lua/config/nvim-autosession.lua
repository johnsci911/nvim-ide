local session_dir = vim.fn.expand('~/nvim-sessions')
if vim.fn.isdirectory(session_dir) == 0 then
  vim.fn.mkdir(session_dir, "p")
end

require('auto-session').setup({
  auto_session_root_dir = session_dir,
  auto_save = true,
  auto_restore = true,
  auto_create = false,
  auto_restore_last_session = true,
  cwd_change_handling = {
    restore_upcoming_session = true,
  },
  session_lens = {
    load_on_setup = true,
    theme_conf = { border = true },
    previewer = false
  }
})

-- Floating input prompt function
local function floating_input(prompt, callback)
  local buf = vim.api.nvim_create_buf(false, true)
  local width, height = 40, 1
  local opts = {
    relative = "editor",
    width = width,
    height = height,
    row = (vim.o.lines - height) / 2 - 1,
    col = (vim.o.columns - width) / 2,
    style = "minimal",
    border = "rounded",
  }
  local win = vim.api.nvim_open_win(buf, true, opts)
  vim.api.nvim_buf_set_option(buf, "buftype", "prompt")
  vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
  vim.fn.prompt_setprompt(buf, prompt .. " ")
  vim.fn.prompt_setcallback(buf, function(input)
    vim.cmd("stopinsert")
    vim.api.nvim_win_close(win, true)
    callback(input)
  end)
  vim.cmd("startinsert")
end

-- User command to save session with floating prompt
vim.api.nvim_create_user_command("SaveSession", function()
  floating_input("Session name:", function(input)
    if input and input ~= "" then
      vim.cmd("AutoSession save " .. input)
      print("Session saved: " .. input)
    else
      print("Session save cancelled")
    end
  end)
end, { desc = "Save session with name" })

