return {
    "nvim-treesitter/nvim-treesitter",
    build = function()
        require('nvim-treesitter.install').update({ with_sync = true })
    end,
    opts = {
        ensure_installed = 'all',
        sync_install = false,
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
        incremental_selection = {
            enable = true,
            keymaps = {
                init_selection = '<c-/>',
                node_incremental = '<c-/>',
                scope_incremental = '<c-s>',
                node_decremental = '<c-.>',
            },
        },
        textobjects = {
            select = {
                enable = true,
                lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
                keymaps = {
                    -- You can use the capture groups defined in textobjects.scm
                    ['aa'] = '@parameter.outer',
                    ['ia'] = '@parameter.inner',
                    ['af'] = '@function.outer',
                    ['if'] = '@function.inner',
                    ['ac'] = '@class.outer',
                    ['ic'] = '@class.inner',
                    ['ii'] = '@conditional.inner',
                    ['ai'] = '@conditional.outer',
                    ['il'] = '@loop.inner',
                    ['al'] = '@loop.outer',
                    ['at'] = '@comment.outer',
                },
            },
            move = {
                enable = true,
                set_jumps = true, -- whether to set jumps in the jumplist
                goto_next_start = {
                    [']m'] = '@function.outer',
                    [']]'] = '@class.outer',
                },
                goto_next_end = {
                    [']M'] = '@function.outer',
                    [']['] = '@class.outer',
                },
                goto_previous_start = {
                    ['[m'] = '@function.outer',
                    ['[['] = '@class.outer',
                },
                goto_previous_end = {
                    ['[M'] = '@function.outer',
                    ['[]'] = '@class.outer',
                },
                -- goto_next = {
                --   [']i'] = "@conditional.inner",
                -- },
                -- goto_previous = {
                --   ['[i'] = "@conditional.inner",
                -- }
            },
            swap = {
                enable = true,
                swap_next = {
                    ['<leader>a'] = '@parameter.inner',
                },
                swap_previous = {
                    ['<leader>A'] = '@parameter.inner',
                },
            },
            additional_vim_regex_highlighting = false,
        },
    },
    config = function(_, opts)
        local parser_config = require('nvim-treesitter.parsers').get_parser_configs()

        parser_config.blade = {
            install_info = {
                url = "https://github.com/EmranMR/tree-sitter-blade",
                files = {"src/parser.c"},
                branch = "main",
            },
            filetype = "blade"
        }

        require('nvim-treesitter.configs').setup(opts)

    end,
    dependencies = {
        'nvim-treesitter/nvim-treesitter-textobjects',
        'nvim-treesitter/nvim-treesitter-context',
        'nvim-treesitter/playground',
    },
}
