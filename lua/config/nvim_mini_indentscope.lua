require('mini.indentscope').setup {
    symbol = "|",
    options = {
        try_as_border = true,
        indent_at_cursor = true,
    },
    draw = {
        delay = 10,
    },
    vim.api.nvim_create_autocmd("FileType", {
        pattern = {
            "help",
            "alpha",
            "dashboard",
            "nvimtree",
            "Trouble",
            "trouble",
            "lazy",
            "mason",
            "notify",
        },
        callback = function()
            vim.b.miniindentscope_disable = true
        end,
    }),
}
