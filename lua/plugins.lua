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
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
      dashboard = {
        enabled = true,
        preset = {
          -- Used by the `header` section
          header = [[
    _  ___   ________  ___    ___  ___  ____
   / |/ / | / /  _/  |/  /___/ _ \/ _ \/ __/
/    /| |/ // // /|_/ /___/ ___/ // / _/
 /_/|_/ |___/___/_/  /_/   /_/  /____/___/  ]],
          keys = {
            { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
            { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
            { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
            { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
            { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
            { icon = " ", key = "s", desc = "Restore Session", section = "session" },
            { icon = "󰒲 ", key = "L", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
            { icon = " ", key = "q", desc = "Quit", action = ":qa" },
          },
        },
        sections = {
          {
            pane = 1,
            { section = "header" },
            { section = "keys",  gap = 0 },
          },
          {
            pane = 2,
            { icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = { 2, 2 } },
            { icon = " ", title = "Projects", section = "projects", indent = 2, padding = 2 },
            { section = "startup" },
          },
        },
      },
      explorer = { enabled = true },
      -- indent = { enabled = false },
      -- input = { enabled = true },
      picker = { enabled = true },
      -- notifier = { enabled = true },
      -- quickfile = { enabled = true },
      -- scope = { enabled = true },
      -- scroll = { enabled = true },
      -- statuscolumn = { enabled = true },
      -- words = { enabled = true },
    },
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
    commit = "49be0a5c6c6662679074a2a560c80b7053de89d7",
    build = "./dl_binaries.sh"
  },

  -- AI Code Companion
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
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
  {
    "Davidyz/VectorCode",
    version = "*",                     -- optional, depending on whether you're on nightly or release
    build = "pipx upgrade vectorcode", -- optional but recommended. This keeps your CLI up-to-date.
    dependencies = { "nvim-lua/plenary.nvim" },
  },

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

  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = { options = { "buffers", "curdir", "tabpages", "winsize", "help", "globals" } },
    -- stylua: ignore
    keys = {
      { "<leader>Sr", function() require("persistence").load() end,                desc = "Restore Session" },
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

  -- TMUX navigation
  'christoomey/vim-tmux-navigator',

  -- Typist
  'nvzone/typr',
  'nvzone/volt',
})
