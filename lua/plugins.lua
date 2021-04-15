-- Packer
local execute = vim.api.nvim_command
local fn = vim.fn

local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'

if fn.empty(fn.glob(install_path)) > 0 then
    execute('!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
    execute 'packadd packer.nvim'
end

local my = function(file) require(file) end

-- Autocompile when there's changes
vim.cmd 'autocmd BufwritePost plugins.lua PackerCompile'

require('packer').init({display = {auto_clean = false}})

return require('packer').startup(function(use)
    -- Packer itself
    use 'wbthomason/packer.nvim'

    -- LSP
    use 'neovim/nvim-lspconfig'
    use 'glepnir/lspsaga.nvim'
    use 'onsails/lspkind-nvim'
    use 'kosayoda/nvim-lightbulb'
    use 'kabouzeid/nvim-lspinstall'

    -- Debug
    use 'mfussenegger/nvim-dap'

    -- Autocomplete
    use 'hrsh7th/nvim-compe'
    use 'mattn/emmet-vim'
    use 'andymass/vim-matchup'
    
    -- Treesitter
    use {'nvim-treesitter/nvim-treesitter', run = ':TSUpdate'}
    use 'p00f/nvim-ts-rainbow'
    use {'lukas-reineke/indent-blankline.nvim', branch = 'lua'}
    use 'nvim-treesitter/playground'
    use 'JoosepAlviste/nvim-ts-context-commentstring'
    use 'windwp/nvim-ts-autotag'
    use 'windwp/nvim-autopairs'

    -- Icons
    use 'kyazdani42/nvim-web-devicons'
    use 'ryanoasis/vim-devicons'

    -- Status Line and Bufferline
    use { 'glepnir/galaxyline.nvim' }
    use 'akinsho/nvim-bufferline.lua'

    -- Explorer
    use 'kyazdani42/nvim-tree.lua'

    -- Keymappings
    use 'liuchengxu/vim-which-key' 

    -- Git
    use 'f-person/git-blame.nvim'
    use 'lewis6991/gitsigns.nvim'
    use 'kdheepak/lazygit.nvim'

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

    -- Themes
    use 'drewtempelmeyer/palenight.vim'
    use 'sainnhe/sonokai'

    -- Easy Scroll
    use 'karb94/neoscroll.nvim'

    -- Navigation
    use 'unblevable/quick-scope' -- hop may replace you
    use 'phaazon/hop.nvim'
    use 'kevinhwang91/rnvimr'
    use 'nacro90/numb.nvim'

    -- Better Align
    use 'junegunn/vim-easy-align'

    -- Start Screen
    use 'mhinz/vim-startify'

    -- Close buffer
    use 'moll/vim-bbye'

    -- Markdown Preview
    use {'iamcco/markdown-preview.nvim', run = 'cd app && npm install'}
    
    -- Floating Terminal
    use 'voldikss/vim-floaterm'

    -- Comment
    use 'terrortylor/nvim-comment'

    -- Project Rooter
    use 'airblade/vim-rooter'

end)