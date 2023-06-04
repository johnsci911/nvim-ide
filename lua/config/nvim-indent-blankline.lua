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
-- vim.opt.listchars:append("eol:↴")

-- Catpuccin
vim.cmd [[highlight IndentBlanklineIndent1 guibg=macchiato.overlay0 gui=nocombine]]
vim.cmd [[highlight IndentBlanklineIndent1 guifg=macchiato.overlay1 gui=nocombine]]

require("indent_blankline").setup {
    enabled = true,
    space_char_highlight_list = {
        "IndentBlanklineIndent1",
    },

    space_char_blankline = " ",
    show_current_context = true,
    show_current_context_start = true,
    colored_indent_levels = true,
}

