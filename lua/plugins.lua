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

    -- LSP
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "neovim/nvim-lspconfig",

    'onsails/lspkind-nvim',
    'kosayoda/nvim-lightbulb',
    'folke/trouble.nvim',
    "lukas-reineke/indent-blankline.nvim",

    -- Debug Lint
    'mfussenegger/nvim-dap',
    'mfussenegger/nvim-lint',

    -- Autocomplete
    'mattn/emmet-vim',
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-buffer',
    "hrsh7th/nvim-cmp",
    "roobert/tailwindcss-colorizer-cmp.nvim",
    'hrsh7th/vim-vsnip',
    'hrsh7th/cmp-vsnip',
    {
        'tzachar/cmp-tabnine',
        build = './install.sh',
        dependencies = 'hrsh7th/nvim-cmp',
    },

    -- Treesitter
    {'nvim-treesitter/nvim-treesitter', build = ':TSUpdate'},
    'HiPhish/nvim-ts-rainbow2',
    'nvim-treesitter/playground',
    'JoosepAlviste/nvim-ts-context-commentstring',
    'windwp/nvim-autopairs',
    'posva/vim-vue',

    -- Icons
    'kyazdani42/nvim-web-devicons',
    'ryanoasis/vim-devicons',

    -- Status Line and Bufferline
    'romgrk/barbar.nvim',

    -- Keymappings
    'folke/which-key.nvim',

    -- Colors
    'NvChad/nvim-colorizer.lua',

    -- Git
    'f-person/git-blame.nvim',
    'lewis6991/gitsigns.nvim',
    'kdheepak/lazygit.nvim',
    'sindrets/diffview.nvim',

    -- Swap windows
    'wesQ3/vim-windowswap',

    -- Telescope
    'nvim-lua/popup.nvim',
    {
        'nvim-telescope/telescope.nvim', tag = '0.1.1',
        -- or                              , branch = '0.1.1',
        dependencies = { 'nvim-lua/plenary.nvim' }
    },

    {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build'
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
        { "<leader>Ss", function() require("persistence").load() end, desc = "Restore Session" },
        { "<leader>Sl", function() require("persistence").load({ last = true }) end, desc = "Restore Last Session" },
        { "<leader>Sd", function() require("persistence").stop() end, desc = "Don't Save Current Session" },
      },
    },

    'ghassan0/telescope-glyph.nvim',
    'ibhagwan/fzf-lua',
    'dyng/ctrlsf.vim',

    -- Themes
    'folke/tokyonight.nvim',
    'marko-cerovac/material.nvim',
    { "catppuccin/nvim", name = "catppuccin" },
    -- Easy Scroll
    'karb94/neoscroll.nvim',

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
    {'iamcco/markdown-preview.nvim', build = 'cd app && npm install'},

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

    -- Notifications
    'rcarriga/nvim-notify',

    -- Auto tab width
    'tpope/vim-sleuth',
})
