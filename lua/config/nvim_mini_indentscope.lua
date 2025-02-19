require('mini.indentscope').setup {
    version = false,
    symbol = "|",
    options = {
        border = 'both',
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
            "snacks",
            "nvimtree",
            "Trouble",
            "trouble",
            "lazy",
            "mason",
            "notify",
            "NeogitStatus",
            "floaterm",
        },
        callback = function()
            vim.b.miniindentscope_disable = true
        end,
    }),
}
