local toggleterm = require("toggleterm")

toggleterm.setup{
  size = function(term)
    if term.direction == "float" then
      return math.floor(vim.o.columns * 0.35)
    elseif term.direction == "horizontal" then
      return math.floor(vim.o.lines * 0.5)
    end
  end,
  direction = "float",
  open_mapping = [[<c-\>]],
  start_in_insert = true,
  insert_mappings = true,
  terminal_mappings = true,
  persist_size = true,
  persist_mode = true,
  close_on_exit = true,
  auto_scroll = true,
  shade_terminals = true,
  shading_factor = 1,
  shell = vim.o.shell,
  winbar = {
    enabled = true,
    name_formatter = function(term)
      local title = "Term: " .. (term.name or "terminal")
      local width = vim.o.columns or 80
      return title .. string.rep(" ", width - #title)
    end,
  },
  highlights = {
    Normal = { guibg = "#1e222a" },
    NormalFloat = { link = "Normal" },
    FloatBorder = { guifg = "#51afef", guibg = "#1e222a" },
  },
}

local Terminal = require("toggleterm.terminal").Terminal
local terminals = {}

local function is_term_closed(term)
  return not (term and vim.api.nvim_buf_is_valid(term.bufnr))
end

-- Floating input prompt for terminal title
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

-- Create or toggle a named floating terminal
local function create_named_terminal(name)
  if is_term_closed(terminals[name]) then
    terminals[name] = Terminal:new{
      direction = "float",
      size = math.floor(vim.o.columns * 0.35),
      close_on_exit = true,
      display_name = name,
    }
  end
  terminals[name]:toggle()
  vim.api.nvim_buf_set_name(terminals[name].bufnr, name)
end

-- Popup to input terminal title and create terminal
local function create_titled_terminal_popup()
  floating_input("Terminal title:", function(input)
    if input and input ~= "" then
      create_named_terminal(input)
    else
      print("Terminal title is required")
    end
  end)
end

-- Count open terminal buffers
local function get_open_terminals()
  local count = 0
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_get_option(buf, "buftype") == "terminal" and vim.api.nvim_buf_is_loaded(buf) then
      count = count + 1
    end
  end
  return count
end

-- Toggle terminal or create new if none open
local function f1_action()
  if get_open_terminals() == 0 then
    local term = Terminal:new{
      direction = "float",
      size = math.floor(vim.o.columns * 0.35),
      close_on_exit = true,
      display_name = "Terminal",
    }
    term:toggle()
  else
    vim.cmd("ToggleTermToggleAll")
  end
end

return {
  f1_action = f1_action,
  create_titled_terminal_popup = create_titled_terminal_popup,
}

