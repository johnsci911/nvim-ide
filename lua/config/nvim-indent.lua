vim.opt.termguicolors = true
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

vim.cmd [[highlight IndentBlanklineIndent1 guibg=#1F2335 gui=nocombine]]
vim.cmd [[highlight IndentBlanklineIndent2 guibg=#24283B gui=nocombine]]

require("indent_blankline").setup {
    char = " ",
    char_highlight_list = {
        "IndentBlanklineIndent1",
        "IndentBlanklineIndent2",
    },
    space_char_highlight_list = {
        "IndentBlanklineIndent1",
        "IndentBlanklineIndent2",
    },
    show_trailing_blankline_indent = false,
}
