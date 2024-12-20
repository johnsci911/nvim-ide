vim.cmd('set iskeyword+=-') -- treat dash separated words as a word text object"
vim.cmd('set shortmess+=c') -- Don't pass messages to |ins-completion-menu|.
vim.cmd('set inccommand=split') -- Make substitution work in realtime
vim.cmd('set autoindent')
vim.cmd('set copyindent')
vim.o.hidden = true -- Required to keep multiple buffers open multiple buffers
vim.o.title = true
TERMINAL = vim.fn.expand('$TERMINAL')
vim.cmd('let &titleold="'..TERMINAL..'"')
vim.o.titlestring="Neovim"
vim.wo.wrap = false -- Display long lines as just one line
vim.cmd('set whichwrap+=<,>,[,],h,l') -- move to next line with these keys
vim.cmd('syntax on') -- move to next line with these keys
vim.o.pumheight = 10 -- Makes popup menu smaller
vim.o.fileencoding = "utf-8" -- The encoding written to file
vim.o.cmdheight = 1 -- More space for displaying messages
vim.o.mouse = "a" -- Enable your mouse
vim.o.splitbelow = true -- Horizontal splits will automatically be below
vim.o.termguicolors = true -- set term giu colors most terminals support this
vim.o.splitright = true -- Vertical splits will automatically be to the right
vim.o.conceallevel = 0 -- So that I can see `` in markdown files
vim.cmd('set ts=4') -- Insert 2 spaces for a tab
vim.cmd('set sw=4') -- Change the number of space characters inserted for indentation
vim.o.shiftwidth = 4 -- Default showed shiftwidth = 4
vim.o.softtabstop = 4 -- Default softtabstop = 4
vim.bo.expandtab = true -- Converts tabs to spaces
vim.wo.number = true -- set numbered lines
vim.wo.relativenumber = true -- set relative number
vim.wo.cursorline = true -- Enable highlighting of the current line
vim.o.showtabline = 2 -- Always show tabs
vim.o.showmode = false -- We don't need to see things like -- INSERT -- anymore
vim.o.backup = false -- This is recommended by coc
vim.o.writebackup = false -- This is recommended by coc
vim.wo.signcolumn = "yes" -- Always show the signcolumn, otherwise it would shift the text each time
vim.o.updatetime = 300 -- Faster completion
vim.o.timeoutlen = 100 -- By default timeoutlen is 1000 ms
vim.o.clipboard = "unnamed,unnamedplus" -- Copy paste between vim and everything else

if vim.g.neovide then
  vim.o.guifont = "FantasqueSansM Nerd Font:h12"

  -- Blur floating window
  vim.g.neovide_floating_shadow = true
  vim.g.neovide_floating_z_height = 5
  vim.g.neovide_light_angle_degrees = 45
  vim.g.neovide_light_radius = 5
  vim.g.neovide_window_blurred = true
  vim.g.neovide_floating_blur_amount_x = 1.0
  vim.g.neovide_floating_blur_amount_y = 1.0
end

vim.cmd('let g:python3_host_prog = "$VIRTUAL_ENV/bin/python3"')

