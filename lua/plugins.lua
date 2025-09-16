vim.o.sessionoptions = "buffers,curdir,folds,help,tabpages,winsize,winpos,localoptions"

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
  "mhartington/formatter.nvim",
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
  "folke/snacks.nvim",
  "rmagatti/auto-session",
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
  'nvim-lua/plenary.nvim',
  'hrsh7th/nvim-cmp',

  -- AI Code Companion
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "ravitemer/mcphub.nvim",
      "ravitemer/codecompanion-history.nvim",
    },
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "codecompanion" }
  },
  {
    "echasnovski/mini.diff",
    config = function()
      local diff = require("mini.diff")
      diff.setup({
        -- Disabled by default
        source = diff.gen_source.none(),
      })
    end,
  },
  "jellydn/spinner.nvim",
  'milanglacier/minuet-ai.nvim',
  'supermaven-inc/supermaven-nvim',

  -- Treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate'
  },
  'windwp/nvim-ts-autotag',
  'nvim-treesitter/nvim-treesitter-context',
  'nvim-treesitter/playground',
  'windwp/nvim-autopairs',

  -- Notification
  {
    "rcarriga/nvim-notify",
  },

  -- Icons
  'kyazdani42/nvim-web-devicons',
  'ryanoasis/vim-devicons',

  -- Status Line and Bufferline TODO: find tabbar plugin for 0.10.^
  'romgrk/barbar.nvim',

  -- Keymappings
  'folke/which-key.nvim',
  'echasnovski/mini.icons',

  -- Colors
  'NvChad/nvim-colorizer.lua',

  -- Git
  {
    "NeogitOrg/neogit",
    dependencies = {
      "sindrets/diffview.nvim", -- optional - Diff integration
    },
    config = true,
  },
  {
    'isakbm/gitgraph.nvim',
    opts = {
      symbols = {
        merge_commit = 'M',
        commit = '*',
      },
      format = {
        timestamp = '%H:%M:%S %d-%m-%Y',
        fields = { 'hash', 'timestamp', 'author', 'branch_name', 'tag' },
      },
      hooks = {
        on_select_commit = function(commit)
          print('selected commit:', commit.hash)
        end,
        on_select_range_commit = function(from, to)
          print('selected range:', from.hash, to.hash)
        end,
      },
    },
    keys = {
      {
        "<leader>gl",
        function()
          require('gitgraph').draw({}, { all = true, max_count = 5000 })
        end,
        desc = "GitGraph - Draw",
      },
    },
  },
  'f-person/git-blame.nvim',
  'lewis6991/gitsigns.nvim',

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

  'nvim-telescope/telescope-project.nvim',
  {
    'dhruvmanila/telescope-bookmarks.nvim',
    dependencies = {
      'kkharji/sqlite.lua',
    }
  },

  "AckslD/nvim-neoclip.lua",

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
  'thesimonho/kanagawa-paper.nvim',

  -- Navigation
  {
    "folke/flash.nvim",
    event = "VeryLazy",
  },
  'nacro90/numb.nvim',
  'kyazdani42/nvim-tree.lua',

  -- Better Align
  'junegunn/vim-easy-align',

  -- Start Screen
  -- Dashboard not working properly

  -- Close buffer
  'moll/vim-bbye',

  -- Typist
  'nvzone/typr',
  'nvzone/volt',
  {
    "nvzone/minty",
    cmd = { "Shades", "Huefy" },
  },

  -- Floating Terminal
  {
    'akinsho/toggleterm.nvim',
    version = "*",
    config = true
  },

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
  'jkcachero/galaxyline.nvim',

  -- Auto tab width
  'tpope/vim-sleuth',

  -- TMUX navigation
  'christoomey/vim-tmux-navigator',
})
