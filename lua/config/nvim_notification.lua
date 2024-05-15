require('notify').setup {
    background_colour = "#000000",
    render = "default",
    stages = "fade_in_slide_out",
    time_formats = {
      notification = " %a %b %d, %Y -  %H:%M",
      notification_history = " %a %b %d, %Y -  %H:%M"
    },
    max_height = 3,
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
