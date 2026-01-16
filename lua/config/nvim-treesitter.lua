-- Enable treesitter-based highlighting
vim.api.nvim_create_autocmd('FileType', {
    callback = function()
        pcall(vim.treesitter.start)
    end,
})

-- Enable treesitter-based indentation
vim.api.nvim_create_autocmd('FileType', {
    callback = function()
        if vim.treesitter.language.get_lang(vim.bo.filetype) then
            vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
    end,
})

-- Parsers to install (run :TSInstallAll to install)
local ensure_installed = {
    'tsx',
    'html',
    'php',
    'bash',
    'css',
    'javascript',
    'lua',
    'c',
    'c_sharp',
    'cmake',
    'cpp',
    'dockerfile',
    'git_config',
    'git_rebase',
    'go',
    'vue',
    'xml', 'regex',
    'yaml',
    'toml',
    'sql',
    'scss',
    'rust',
    'svelte',
    'ssh_config',
    'vim',
    'typescript',
    'markdown',
    'markdown_inline',
    'yuck',
    'norg',
    'blade'
}

vim.api.nvim_create_user_command('TSInstallAll', function()
    for _, lang in ipairs(ensure_installed) do
        vim.cmd('TSInstall ' .. lang)
    end
end, { desc = 'Install all commonly used treesitter parsers' })

-- Blade support
local parser_config = require("nvim-treesitter.parsers")
parser_config.blade = {
    install_info = {
        url = "https://github.com/EmranMR/tree-sitter-blade",
        files = { "src/parser.c" },
        branch = "main",
    },
    filetype = "blade"
}

vim.filetype.add({
    pattern = {
        ['.*%.blade%.php'] = 'blade',
        ['.*%.html%.jinja'] = 'htmldjango',
        ['.*%.html%.jinja2'] = 'htmldjango',
        ['.*%.html%.j2'] = 'htmldjango',
    }
})

-- Incremental selection keymaps
vim.keymap.set('n', '<Leader>,s', ':TSUpdate<CR>', { desc = 'Treesitter: Update' })
vim.keymap.set('n', '<Leader>,i', ':TSInstallInfo<CR>', { desc = 'Treesitter: Install Info' })

-- Neorg conceal
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
    pattern = { "*.norg" },
    command = "set conceallevel=3"
})

-- Treesitter configuration
require('nvim-treesitter.configs').setup({
    -- Enable syntax highlighting
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
    
    -- Auto install parsers when entering a buffer
    auto_install = false,
    
    -- Parsers to ensure are installed
    ensure_installed = ensure_installed,
    
    -- Playground configuration
    playground = {
        enable = true,
        disable = {},
        updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
        persist_queries = false, -- Whether the query persists across vim sessions
        keybindings = {
            toggle_query_editor = 'o',
            toggle_hl_groups = 'i',
            toggle_injections = 't',
            toggle_anonymous_nodes = 'a',
            toggle_language_display = 'I',
            focus_language = 'f',
            unfocus_language = 'F',
            update = 'R',
            goto_node = '<cr>',
            show_help = '?',
        },
    }
})

-- Playground keymaps
vim.keymap.set('n', '<Leader>,p', ':TSPlaygroundToggle<CR>', { desc = 'Treesitter: Toggle Playground' })
vim.keymap.set('n', '<Leader>,h', ':TSHighlightCapturesUnderCursor<CR>', { desc = 'Treesitter: Highlight Captures' })
