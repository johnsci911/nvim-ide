require'nvim-treesitter.configs'.setup {
    ensure_installed = 'all', -- one of "all", "maintained" (parsers with maintainers), or a list of languages
    -- TODO seems to be broken
    -- ignore_install = '',
    highlight = {
        enable = true, -- false will disable the whole extension
        disable = {
            "blade",
            "vue"
        }
    },
    -- indent = {enable = true, disable = {"python", "html", "javascript"}},
    indent = {
        enable = true,
		disable = {
            'blade',
            'vue'
        }
    },
    playground = {
        enable = true,
        disable = {},
        updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
        persist_queries = false -- Whether the query persists across vim sessions
    },
    autotag = {enable = true},
    rainbow = {enable = true},
    context_commentstring = {enable = true, config = {javascriptreact = {style_element = '{/*%s*/}'}}}
    -- refactor = {highlight_definitions = {enable = true}}
}
