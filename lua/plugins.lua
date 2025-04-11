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
        },
        sections = {
          {
            pane = 1,
            { section = "header" },
            { section = "keys", gap = 0 },
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
  {
    "yetone/avante.nvim",
    version = "0.0.15",
    event = "VeryLazy",
    lazy = false,

    -- OpenAI
    -- opts = {
    --   provider = "openai",
    --   auto_suggestions_provider = "openai",
    --   openai = {
    --     endpoint = "https://api.openai.com/v1",
    --     model = "gpt-4o-mini",
    --     timeout = 30000, -- timeout in milliseconds
    --     temperature = 0,
    --     max_tokens = 4096,
    --   },
    -- },

    -- Ollama
    opts = {
      -- provider = "openai",
      provider = "ollama",
      use_absolute_path = true,
      openai = {
        endpoint = "https://api.openai.com/v1",
        model = "gpt-4o-mini",
        timeout = 30000, -- timeout in milliseconds
        temperature = 0,
        max_tokens = 4096,
      },
      vendors = {
        ollama = {
          __inherited_from = "openai",
          api_key_name = "",
          endpoint = "http://127.0.0.1:11434/v1",
          -- model = "incept5/llama3.1-claude:latest", -- Llama3.1 with Anthropic's Claude Sonnet 3.5 prompt
          model = "qwen2.5-coder:7b", -- Qwen 2.5 Coder 7B
        },
      },
      -- dual_boost = {
      --   enabled = false,
      --   first_provider = "ollama",
      --   second_provider = "openai",
      --   prompt =
      --   "Based on the two reference outputs below, generate a response that incorporates elements from both but reflects your own judgment and unique perspective. Do not provide any explanation, just give the response directly. Reference Output 1: [{{provider1_output}}], Reference Output 2: [{{provider2_output}}]",
      --   timeout = 60000, -- Timeout in milliseconds
      -- },
      behaviour = {
        auto_suggestions = false, -- I have tabnine to handle this
        auto_set_highlight_group = true,
        auto_set_keymaps = true,
        auto_apply_diff_after_generation = false,
        support_paste_from_clipboard = true,
      },
      mappings = {
        --- @class AvanteConflictMappings
        diff = {
          ours = 'co',
          theirs = 'ct',
          all_theirs = 'ca',
          both = 'cb',
          cursor = 'cc',
          next = ']x',
          prev = '[x',
        },
        suggestion = {
          accept = '<M-l>',
          next = '<M-]>',
          prev = '<M-[>',
          dismiss = '<C-]>',
        },
        jump = {
          next = ']]',
          prev = '[[',
        },
        submit = {
          normal = '<CR>',
          insert = '<C-s>',
        },
      },
      hints = { enabled = true },
      windows = {
        ---@type "right" | "left" | "top" | "bottom"
        position = 'right', -- the position of the sidebar
        wrap = true,        -- similar to vim.o.wrap
        width = 40,         -- default % based on available width
        sidebar_header = {
          align = 'center', -- left, center, right for title
          rounded = true,
        },
      },
      highlights = {
        ---@type AvanteConflictHighlights
        diff = {
          current = 'DiffText',
          incoming = 'DiffAdd',
        },
      },
      --- @class AvanteConflictUserConfig
      diff = {
        autojump = true,
        ---@type string | fun(): any
        list_opener = 'copen',
      },
    },

    -- Deep Seek model integration
    -- opts = {
    --   provider = "openai",
    --   auto_suggestions_provider = "openai", -- Since auto-suggestions are a high-frequency operation and therefore expensive, it is recommended to specify an inexpensive provider or even a free provider: copilot
    --   openai = {
    --     endpoint = "https://api.deepseek.com/v1",
    --     model = "deepseek-chat",
    --     timeout = 30000, -- Timeout in milliseconds
    --     temperature = 0,
    --     max_tokens = 4096,
    --   },
    -- },
    --
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    build = "make",
    -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
    dependencies = {
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- The below dependencies are optional,
      "echasnovski/mini.pick",         -- for file_selector provider mini.pick
      "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
      "hrsh7th/nvim-cmp",              -- autocompletion for avante commands and mentions
      "ibhagwan/fzf-lua",              -- for file_selector provider fzf
      "nvim-tree/nvim-web-devicons",   -- or echasnovski/mini.icons
      "zbirenbaum/copilot.lua",        -- for providers='copilot'
      {
        -- support for image pasting
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            -- required for Windows users
            use_absolute_path = true,
          },
        },
      },
      {
        -- Make sure to set this up properly if you have lazy=true
        'MeanderingProgrammer/render-markdown.nvim',
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
    },
  },

  -- Treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate'
  },
  'windwp/nvim-ts-autotag',
  'nvim-treesitter/nvim-treesitter-context',
  'HiPhish/nvim-ts-rainbow2',
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
  'projekt0n/caret.nvim',
  "rjshkhr/shadow.nvim",

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

  -- Markdown Preview
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = "cd app && yarn install",
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
    ft = { "markdown" },
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

  -- TMUX navigation
  'christoomey/vim-tmux-navigator',

  -- Typist
  'nvzone/typr',
  'nvzone/volt',
})
