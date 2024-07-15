local api = vim.api
api.nvim_command("autocmd TermOpen * setlocal nonumber norelativenumber")

vim.g.floaterm_gitcommit = 'floaterm'
vim.g.floaterm_shell = 'zsh'
vim.g.floaterm_autoinsert = 1
vim.g.floaterm_width = 0.9
vim.g.floaterm_height = 0.4
vim.g.floaterm_title = 'Terminal: $1/$2'
vim.g.floaterm_autoclose = 2
vim.g.floaterm_position = 'bottom'
vim.g.floaterm_wintype = 'split'
vim.g.floaterm_titleposition = 'center'
