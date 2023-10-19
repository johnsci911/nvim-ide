require'nvim-treesitter.configs'.setup {
    ensure_installed = 'all', -- one of "all", "maintained" (parsers with maintainers), or a list of languages
    highlight = {
        enable = true, -- false will disable the whole extension
        disable = {
            'vue',
        }
    },
    indent = {
        enable = true,
        disable = {
            -- "python",
            -- "html",
            -- "javascript",
            -- "php",
        }
    },
    playground = {
        enable = true,
        disable = {},
        updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
        persist_queries = false -- Whether the query persists across vim sessions
    },
    autotag = {enable = true},
    context_commentstring = {
        enable = true,
        config = {
            javascriptreact = {
                style_element = '{/*%s*/}'
            }
        }
    },
    refactor = {
        highlight_definitions = {enable = true}
    },
    rainbow = {
        enable = true,
        -- list of languages you want to disable the plugin for
        disable = { 'jsx', 'cpp' },
        -- Which query to use for finding delimiters
        query = 'rainbow-parens',
        -- Highlight the entire buffer all at once
        strategy = require('ts-rainbow').strategy.global,
    }
}

local parser_config = require "nvim-treesitter.parsers".get_parser_configs()

parser_config.blade = {
    install_info = {
        url = "https://github.com/EmranMR/tree-sitter-blade",
        files = {"src/parser.c"},
        branch = "main",
    },
    filetype = "blade"
}

vim.filetype.add({
    pattern = {
        ['.*%.blade%.php'] = 'blade',
    },
})
