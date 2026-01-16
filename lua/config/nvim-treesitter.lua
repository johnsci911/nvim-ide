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
