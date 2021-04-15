vim.o.termguicolors = true

vim.api.nvim_set_keymap('n', '<TAB>', ':BufferLineCycleNext<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<S-TAB>', ':BufferLineCyclePrev<CR>', { noremap = true, silent = true })

require'bufferline'.setup{
    options = {
        view = "multiwindow",
        left_trunc_marker = '',
        right_trunc_marker = '',
        max_name_length = 18,
        diagnostics = "nvim_lsp",
        show_close_icon = false,
        diagnostics_indicator = function(count, level)
            local icon = level:match("error") and " " or " "
            return " " .. icon .. count
        end,
        separator_style = "thin",
        sort_by = 'relative_directory'
    }
}