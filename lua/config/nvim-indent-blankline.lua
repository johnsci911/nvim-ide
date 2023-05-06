vim.opt.termguicolors = true

vim.cmd [[highlight IndentBlanklineIndent1 guibg=#1E1E2E gui=nocombine]]
vim.cmd [[highlight IndentBlanklineIndent1 guifg=#3B4459 gui=nocombine]]

vim.opt.list = true
vim.opt.listchars:append("space:⋅")
vim.g.indentLine_bufNameExclude = {
    'defx',
    'packager',
    'vista',
    'NvimTree',
    'DiffviewFiles',
    'ctrlsf',
    'dashboard',
    'floaterm',
}

vim.opt.list = true
vim.opt.listchars:append("space:⋅")
-- vim.opt.listchars:append("eol:↴")

require("indent_blankline").setup {
    enabled = true,
    char_highlight_list = {
        "IndentBlanklineIndent1",
    },
    space_char_highlight_list = {
        "IndentBlanklineIndent1",
    },

    space_char_blankline = " ",
    show_current_context = true,
    show_current_context_start = true,
    colored_indent_levels = true,
}
