vim.cmd([[
    let g:auto_session_pre_save_cmds = ["tabdo NvimTreeClose"]
]])

vim.g.mapleader = " "

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    -- Lazyvim
    'folke/lazy.nvim',
    {
        'stevearc/aerial.nvim',
        opts = {},
        -- Optional dependencies
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-tree/nvim-web-devicons"
        },
    },

    -- LSP
    {
        "mhartington/formatter.nvim",
        event = "VeryLazy",
        opts = function()
            return require "config.nvim-formatter"
        end
    },
    {
        "williamboman/mason.nvim",
        opts = {
            ensure_installed = {
                'eslint-lsp',
                'prettier',
                'typescript-language-server',
            }
        }
    },
    {
        'folke/trouble.nvim',
        branch = "main",
    },
    "williamboman/mason-lspconfig.nvim",
    "neovim/nvim-lspconfig",

    'onsails/lspkind-nvim',
    'kosayoda/nvim-lightbulb',

    -- Indentations
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        opts = {},
    },
    "echasnovski/mini.indentscope",

    -- Debug Lint
    'mfussenegger/nvim-dap',
    'mfussenegger/nvim-lint',

    -- Autocomplete
    'mattn/emmet-vim',
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-buffer',
    'roobert/tailwindcss-colorizer-cmp.nvim',
    'hrsh7th/vim-vsnip',
    'hrsh7th/cmp-vsnip',
    {
        'tzachar/cmp-tabnine',
        build = './install.sh',
        dependencies = 'hrsh7th/nvim-cmp',
    },
    {
        'codota/tabnine-nvim',
        build = "./dl_binaries.sh"
    },

    -- Treesitter
    { 'nvim-treesitter/nvim-treesitter', build = ':TSUpdate' },
    'windwp/nvim-ts-autotag',
    'nvim-treesitter/nvim-treesitter-context',
    'HiPhish/nvim-ts-rainbow2',
    'nvim-treesitter/playground',
    'windwp/nvim-autopairs',
    'posva/vim-vue',

    -- Notification
    {
        "folke/noice.nvim",
        event = "VeryLazy",
        opts = {
            -- add any options here
        },
        dependencies = {
            -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
            "MunifTanjim/nui.nvim",
            -- OPTIONAL:
            --   `nvim-notify` is only needed, if you want to use the notification view.
            --   If not available, we use `mini` as the fallback
            "rcarriga/nvim-notify",
        }
    },

    -- Icons
    'kyazdani42/nvim-web-devicons',
    'ryanoasis/vim-devicons',

    -- Status Line and Bufferline
    {
        'romgrk/barbar.nvim',
        version = '^1.0.0'
    },

    -- Keymappings
    'folke/which-key.nvim',

    -- Colors
    'NvChad/nvim-colorizer.lua',

    -- Git
    {
        "NeogitOrg/neogit",
        branch = "decouple-global-statusbuffer",
        dependencies = {
            "sindrets/diffview.nvim", -- optional - Diff integration
        },
        config = true,
    },
    'f-person/git-blame.nvim',
    'lewis6991/gitsigns.nvim',

    -- Swap windows
    'wesQ3/vim-windowswap',

    -- Telescope
    'nvim-lua/popup.nvim',
    {
        'nvim-telescope/telescope.nvim',
        dependencies = {
            'nvim-lua/plenary.nvim',
            "Snikimonkd/telescope-git-conflicts.nvim",
        }
    },
    {
        'nvim-telescope/telescope-fzf-native.nvim',
        build =
        'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build'
    },

    -- Code preview
    {
        'michaelrommel/nvim-silicon',
        lazy = true,
        cmd = "Silicon",
    },

    'nvim-telescope/telescope-media-files.nvim',
    'nvim-telescope/telescope-project.nvim',
    {
        'dhruvmanila/telescope-bookmarks.nvim',
        dependencies = {
            'kkharji/sqlite.lua',
        }
    },

    "AckslD/nvim-neoclip.lua",

    {
        "folke/persistence.nvim",
        event = "BufReadPre",
        opts = { options = { "buffers", "curdir", "tabpages", "winsize", "help", "globals" } },
        -- stylua: ignore
        keys = {
            { "<leader>Ss", function() require("persistence").load() end,                desc = "Restore Session" },
            { "<leader>Sl", function() require("persistence").load({ last = true }) end, desc = "Restore Last Session" },
            { "<leader>Sd", function() require("persistence").stop() end,                desc = "Don't Save Current Session" },
        },
    },

    -- Org Mode
    {
        'nvim-neorg/neorg',
        dependencies = { 'luarocks.nvim' },
        lazy = false, -- Disable lazy loading as some `lazy.nvim` distributions set `lazy = true` by default
        version = "v7.0.0",
        config = true,
    },
    {
        "vhyrro/luarocks.nvim",
        priority = 1000,
        config = true,
    },

    'ghassan0/telescope-glyph.nvim',
    'ibhagwan/fzf-lua',
    'dyng/ctrlsf.vim',

    -- Themes
    'folke/tokyonight.nvim',
    'marko-cerovac/material.nvim',
    {
        "catppuccin/nvim",
        name = "catppuccin"
    },

    -- Navigation
    'phaazon/hop.nvim',
    'nacro90/numb.nvim',
    'kyazdani42/nvim-tree.lua',

    -- Better Align
    'junegunn/vim-easy-align',

    -- Start Screen
    -- Dashboard not working properly

    -- Close buffer
    'moll/vim-bbye',

    -- Markdown Preview
    {
        "iamcco/markdown-preview.nvim",
        cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
        ft = { "markdown" },
        build = function() vim.fn["mkdp#util#install"]() end,
    },
    -- Floating Terminal
    'voldikss/vim-floaterm',

    -- Comment
    'terrortylor/nvim-comment',

    -- Project Rooter
    "airblade/vim-rooter",

    -- Multi cursor support
    'mg979/vim-visual-multi',

    -- Strip WhiteSpace
    "ntpeters/vim-better-whitespace",

    -- EWW language support
    "elkowar/yuck.vim",

    -- Dockerfile syntax highlighting
    "ekalinin/Dockerfile.vim",

    -- Galaxyline
    'glepnir/galaxyline.nvim',

    -- Auto tab width
    'tpope/vim-sleuth',
})
