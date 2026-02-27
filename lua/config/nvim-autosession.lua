local session_dir = vim.fn.expand('~/nvim-sessions')
if vim.fn.isdirectory(session_dir) == 0 then
  vim.fn.mkdir(session_dir, "p")
end

-- Only treat directories with a .git folder as projects
local function is_git_repo()
  return vim.fn.isdirectory(vim.fn.getcwd() .. '/.git') == 1
end

require('auto-session').setup({
  auto_session_root_dir = session_dir,
  auto_save = false,    -- controlled via VimLeave below
  auto_restore = false, -- controlled via VimEnter below
  auto_create = false,  -- session created implicitly on first VimLeave save
  use_git_branch = true, -- separate session per branch (e.g. main vs feature-x)
  cwd_change_handling = {
    restore_upcoming_session = true,
  },
  session_lens = {
    load_on_setup = true,
    theme_conf = { border = true },
    previewer = true
  }
})

-- Auto-restore on startup: only for git repos, only when nvim was opened bare (no file args)
vim.api.nvim_create_autocmd("VimEnter", {
  nested = true,
  callback = vim.schedule_wrap(function()
    if vim.fn.argc() == 0 and is_git_repo() then
      require('auto-session').RestoreSession()
    end
  end),
})

-- Auto-save on exit: only for git repos
vim.api.nvim_create_autocmd("VimLeave", {
  callback = function()
    if is_git_repo() then
      require('auto-session').SaveSession()
    end
  end,
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

-- User command to rename current session with floating prompt
vim.api.nvim_create_user_command("RenameSession", function()
  local current = require('auto-session.lib').current_session_name()
  if not current or current == '' then
    print('No active session to rename')
    return
  end
  floating_input('Rename (' .. current .. '):', function(input)
    if not input or input == '' then
      print('Session rename cancelled')
      return
    end
    local old_path = session_dir .. '/' .. current .. '.vim'
    local new_path = session_dir .. '/' .. input .. '.vim'
    if vim.fn.filereadable(new_path) == 1 then
      print('Session "' .. input .. '" already exists')
      return
    end
    if vim.fn.rename(old_path, new_path) == 0 then
      print('Session renamed: ' .. current .. ' -> ' .. input)
    else
      print('Failed to rename session')
    end
  end)
end, { desc = 'Rename current session' })
