vim.opt.termguicolors = true

vim.cmd [[highlight IndentBlanklineIndent1 guibg=#1E1E2E gui=nocombine]]
vim.cmd [[highlight IndentBlanklineIndent2 guibg=#2A2B3C gui=nocombine]]

vim.cmd [[highlight IndentBlanklineIndent1 guifg=#696D7F gui=nocombine]]
vim.cmd [[highlight IndentBlanklineIndent2 guifg=#696D7F gui=nocombine]]

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
vim.opt.listchars:append("eol:↴")

require("indent_blankline").setup {
    enabled = true,
    char_highlight_list = {
        "IndentBlanklineIndent1",
        "IndentBlanklineIndent2",
    },
    space_char_highlight_list = {
        "IndentBlanklineIndent1",
        "IndentBlanklineIndent2",
    },
    space_char_blankline = " ",
    show_current_context = true,
    colored_indent_levels = false,
}
