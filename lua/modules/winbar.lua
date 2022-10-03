vim.api.nvim_create_autocmd('BufWinEnter', {
    pattern = '*',
    callback = function()
        if vim.bo.filetype == '' then
            return
        end

        vim.wo.winbar = "%{%v:lua.require'modules.winbar'.exec()%}"
    end
})

local M = {}
local navic = require("nvim-navic")

navic.setup {
    icons = {
        File          = " ",
        Module        = " ",
        Namespace     = " ",
        Package       = " ",
        Class         = " ",
        Method        = " ",
        Property      = " ",
        Field         = " ",
        Constructor   = " ",
        Enum          = "練",
        Interface     = "練",
        Function      = " ",
        Variable      = " ",
        Constant      = " ",
        String        = " ",
        Number        = " ",
        Boolean       = "◩ ",
        Array         = " ",
        Object        = " ",
        Key           = " ",
        Null          = "ﳠ ",
        EnumMember    = " ",
        Struct        = " ",
        Event         = " ",
        Operator      = " ",
        TypeParameter = " ",
    },
    highlight = true,
    separator = " ",
    depth_limit = 0,
    depth_limit_indicator = "..",
}

local winbar_filetype_exclude = {
    "help",
    "dashboard",
    "packer",
    "NvimTree",
    "Trouble",
    "Outline",
    "floaterm",
}

vim.api.nvim_set_hl(0, 'WinBarPath', { bg = '#24283B', fg = '#B8C1EC' })
vim.api.nvim_set_hl(0, 'NavicText', { bg = '#24283B', fg = '#A98CE1' })

function M.exec()

    if vim.tbl_contains(winbar_filetype_exclude, vim.bo.filetype) then
        return ""
    end

    local file_path = '▎ ' ..  vim.api.nvim_eval_statusline('%t', {}).str .. ' '
    local lsp_navic = navic.get_location()

    return
    '%#WinBarPath#'
    ..  file_path
    .. '%*'
    .. lsp_navic
    .. '%*'
end

return M

