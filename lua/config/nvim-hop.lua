require'hop'.setup { keys = 'etovxqpdygfblzhckisuran', term_seq_bias = 0.5 }

vim.api.nvim_set_keymap('n', 's', ":HopChar2<cr>", {silent = true})
vim.api.nvim_set_keymap('n', 'S', ":HopWord<cr>", {silent = true})
