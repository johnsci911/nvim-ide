local api = vim.api
api.nvim_command("autocmd TermOpen * setlocal nonumber norelativenumber")

vim.g.floaterm_gitcommit = 'floaterm'
vim.g.floaterm_shell = 'zsh'
vim.g.floaterm_autoinsert = 1
vim.g.floaterm_width = 0.9
vim.g.floaterm_height = 0.8
vim.g.floaterm_title = 'Terminal: $1/$2'
vim.g.floaterm_autoclose = 2
vim.g.floaterm_position = 'center'
vim.g.floaterm_wintype = 'float'
vim.g.floaterm_titleposition = 'center'
