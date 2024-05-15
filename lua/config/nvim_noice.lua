require('notify').setup {
    background_colour = "#000000",
    render = "minimal",
    message = {
        height = 1,
    },
    max_height = 1,
}

require('noice').setup {
    lsp = {
        override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true,
        }
    },
    routes = {
        {
            filter = {
                event = "msg_showmode",
                any = {
                    { find = "%d+L, %d+B" },
                    { find = "; after #%d+" },
                    { find = "; before #%d+" },
                },
            },
            view = "notify",
        },
    },
    views = {
        cmdline_popup = {
            border = {
                style = "none",
                padding = { 2, 3 },
            },
            filter_options = {},
            win_options = {
                winhighlight = "NormalFloat:NormalFloat,FloatBorder:FloatBorder",
            },
        },
    },
}
