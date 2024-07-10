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
        progress = {
            enabled = true,
            -- Lsp Progress is formatted using the builtins for lsp_progress. See config.format.builtin
            -- See the section on formatting for more details on how to customize.
            --- @type NoiceFormat|string
            format = "lsp_progress",
            --- @type NoiceFormat|string
            format_done = "lsp_progress_done",
            throttle = 1000 / 30, -- frequency to update lsp progress message
            view = "mini",
        },
        override = {
            -- override the default lsp markdown formatter with Noice
            ["vim.lsp.util.convert_input_to_markdown_lines"] = false,
            -- override the lsp markdown formatter with Noice
            ["vim.lsp.util.stylize_markdown"] = false,
            -- override cmp documentation with Noice (needs the other options to work)
            ["cmp.entry.get_documentation"] = false,
        },
        hover = {
            enabled = true,
            silent = true, -- set to true to not show a message if hover is not available
            view = nil,     -- when nil, use defaults from documentation
            ---@type NoiceViewOptions
            opts = {},      -- merged with defaults from documentation
        },
        signature = {
            enabled = true,
            auto_open = {
                enabled = true,
                trigger = true, -- Automatically show signature help when typing a trigger character from the LSP
                luasnip = true, -- Will open signature help when jumping to Luasnip insert nodes
                throttle = 50,  -- Debounce lsp signature help request by 50ms
            },
            view = nil,         -- when nil, use defaults from documentation
            ---@type NoiceViewOptions
            opts = {},          -- merged with defaults from documentation
        },
        message = {
            -- Messages shown by lsp servers
            enabled = true,
            view = "notify",
            opts = {},
        },
        -- defaults for hover and signature help
        documentation = {
            view = "hover",
            ---@type NoiceViewOptions
            opts = {
                lang = "markdown",
                replace = true,
                render = "plain",
                format = { "{message}" },
                win_options = { concealcursor = "n", conceallevel = 3 },
            },
        },
    },
    presets = {
        bottom_search = true,         -- use a classic bottom cmdline for search
        command_palette = true,       -- position the cmdline and popupmenu together
        long_message_to_split = true, -- long messages will be sent to a split
        inc_rename = false,           -- enables an input dialog for inc-rename.nvim
        lsp_doc_border = false,       -- add a border to hover docs and signature help
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
