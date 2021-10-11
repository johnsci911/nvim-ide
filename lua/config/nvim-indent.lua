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

vim.opt.list = true
vim.opt.listchars:append("space:⋅")
vim.opt.listchars:append("eol:↴")

require("indent_blankline").setup {
    space_char_blankline = " ",
    show_current_context = true,
}
