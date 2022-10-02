local M = {}

local winbar_filetype_exclude = {
    "help",
    "dashboard",
    "packer",
    "NvimTree",
    "Trouble",
    "Outline",
    "floaterm",
}

-- #4A3E4B
-- vim.api.nvim_set_hl(0, 'WinBarPath', { bg = '#4A3E4B', fg = '#C1ADC4' })
-- vim.api.nvim_set_hl(0, 'WinBarModified', { bg = '#dedede', fg = '#ff3838' })

function M.statusline()

    if vim.tbl_contains(winbar_filetype_exclude, vim.bo.filetype) then
        return ""
    end

    local file_path = vim.api.nvim_eval_statusline('%F', {}).str
    local modified = vim.api.nvim_eval_statusline('%M', {}).str == '+' and '⊚' or ''

    file_path = file_path:gsub('/', ' ➤ ')
    file_path = file_path:gsub('~', ' $HOME')

    return '%#WinBarPath#'
     .. file_path..' '
     .. '%*'
     .. modified .. ' '
     .. '%*'

end

return M
