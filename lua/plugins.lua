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
    use 'glepnir/lspsaga.nvim'
    use 'onsails/lspkind-nvim'
    use 'kosayoda/nvim-lightbulb'
    use 'kabouzeid/nvim-lspinstall'
    use 'folke/lsp-trouble.nvim'

    -- Debug
    use 'mfussenegger/nvim-dap'

    -- Autocomplete
    use 'hrsh7th/nvim-compe'
    use 'hrsh7th/vim-vsnip'
    use 'mattn/emmet-vim'
    use 'andymass/vim-matchup'

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
    use 'glepnir/galaxyline.nvim'
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
    use 'nvim-lua/plenary.nvim'
    use 'nvim-telescope/telescope.nvim'
    use 'nvim-telescope/telescope-media-files.nvim'
    use 'nvim-telescope/telescope-fzy-native.nvim'
    use 'nvim-telescope/telescope-project.nvim'

    -- Themes
    use 'drewtempelmeyer/palenight.vim'
    use 'folke/tokyonight.nvim'

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

    -- Search and Explore
    use 'dyng/ctrlsf.vim'
    use 'mg979/vim-visual-multi'

    -- Desctruction Free mode
    use "Pocco81/TrueZen.nvim"

	-- Strip WhiteSpace
	use "ntpeters/vim-better-whitespace"
end)
