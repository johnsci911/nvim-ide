-- Packer
local execute = vim.api.nvim_command
local fn = vim.fn

local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'

if fn.empty(fn.glob(install_path)) > 0 then
    execute('!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
    execute 'packadd packer.nvim'
end

-- Autocompile when there's changes
vim.cmd 'autocmd BufwritePost plugins.lua PackerCompile'

require('packer').init({display = {auto_clean = false}})

local packer = require('packer');

packer.init {
    display = {
        open_fn = function()
            return require("packer.util").float { border = "single" }
        end,
    },
}

return packer.startup(function(use)
    -- Packer itself
    use 'wbthomason/packer.nvim'

    -- LSP
    use 'neovim/nvim-lspconfig'
    use 'onsails/lspkind-nvim'
    use 'kosayoda/nvim-lightbulb'
    use 'williamboman/nvim-lsp-installer'
    use 'folke/trouble.nvim'
    use "lukas-reineke/indent-blankline.nvim"

    -- Debug
    use 'mfussenegger/nvim-dap'

    -- Autocomplete
    use 'mattn/emmet-vim'
    use 'hrsh7th/cmp-nvim-lsp'
    use 'hrsh7th/cmp-buffer'
    use 'hrsh7th/nvim-cmp'
    use 'hrsh7th/vim-vsnip'
    use 'hrsh7th/cmp-vsnip'
    use {'tzachar/cmp-tabnine', run='./install.sh'}

    -- Treesitter
    use {'nvim-treesitter/nvim-treesitter', branch = '0.5-compat', run = ':TSUpdate'}
    use 'nvim-treesitter/playground'
    use 'JoosepAlviste/nvim-ts-context-commentstring'
    use 'windwp/nvim-autopairs'
    use 'posva/vim-vue'

    -- Icons
    use 'kyazdani42/nvim-web-devicons'
    use 'ryanoasis/vim-devicons'

    -- Status Line and Bufferline
    -- Find galagxyline replacement
    use 'romgrk/barbar.nvim'

    -- Keymappings
    use 'folke/which-key.nvim'

    -- Git
    use 'f-person/git-blame.nvim'
    use 'lewis6991/gitsigns.nvim'
    use 'kdheepak/lazygit.nvim'
    use 'sindrets/diffview.nvim'

    -- Swap windows
    use 'wesQ3/vim-windowswap'

    -- Colors
    use 'norcalli/nvim-colorizer.lua'
    use 'junegunn/rainbow_parentheses.vim'

    -- Telescope
    use 'nvim-lua/popup.nvim'
    use {
        'nvim-telescope/telescope.nvim',
        requires = {
            use 'nvim-lua/plenary.nvim'
        }
    }
    use 'nvim-telescope/telescope-media-files.nvim'
    use {'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
    use 'nvim-telescope/telescope-project.nvim'

    -- Fuzy find
    use {
        'ibhagwan/fzf-lua',
        requires = {
            'vijaymarupudi/nvim-fzf',
        }
    }
    use 'dyng/ctrlsf.vim'

    -- Themes
    use 'folke/tokyonight.nvim'
    use 'marko-cerovac/material.nvim'
    use 'shaunsingh/nord.nvim'

    -- Easy Scroll
    use 'karb94/neoscroll.nvim'

    -- Navigation
    use 'phaazon/hop.nvim'
    use 'nacro90/numb.nvim'
    use 'kyazdani42/nvim-tree.lua'

    -- Better Align
    use 'junegunn/vim-easy-align'

    -- Start Screen
    use 'glepnir/dashboard-nvim'

    -- Close buffer
    use 'moll/vim-bbye'

    -- Markdown Preview
    use {'iamcco/markdown-preview.nvim', run = 'cd app && npm install'}

    -- Floating Terminal
    use 'voldikss/vim-floaterm'

    -- Comment
    use 'terrortylor/nvim-comment'

    -- Project Rooter
    use "airblade/vim-rooter"

    -- Config Reloader
    use 'famiu/nvim-reload'

    -- Laravel
    use 'jwalton512/vim-blade'

    -- Multi cursor support
    use 'mg979/vim-visual-multi'

    -- Desctruction Free mode
    use "Pocco81/TrueZen.nvim"

    -- Strip WhiteSpace
    use "ntpeters/vim-better-whitespace"

    -- EWW language support
    use "elkowar/yuck.vim"

    -- Dockerfile syntax highlighting
    use "ekalinin/Dockerfile.vim"

    -- Galaxyline
    use 'glepnir/galaxyline.nvim'
end)
