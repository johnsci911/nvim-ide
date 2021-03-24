" auto-install vim-plug
if empty(glob('~/.config/nvim/autoload/plug.vim'))
  silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  "autocmd VimEnter * PlugInstall
  autocmd VimEnter * PlugInstall | source $MYVIMRC
endif

call plug#begin('~/.config/nvim/autoload/plugged')

if exists('g:vscode')
  Plug 'machakann/vim-highlightedyank'
else

  " Auto pairs for '(' '[' '{'
  Plug 'jiangmiao/auto-pairs'
  " Quick Scopes
  Plug 'unblevable/quick-scope'
  " Floating Terminal
  Plug 'voldikss/vim-floaterm'
  " Which key
  Plug 'liuchengxu/vim-which-key'
  " FZF
  Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
  Plug 'yuki-ycino/fzf-preview.vim', { 'branch': 'release/remote', 'do': ':UpdateRemotePlugins' }
  Plug 'junegunn/fzf.vim'
  " Vim Rooter
  Plug 'airblade/vim-rooter'
  " Better Comments
  Plug 'tpope/vim-commentary'
  " Ranger File Manager
  Plug 'kevinhwang91/rnvimr'
  " Intellisense
  Plug 'neoclide/coc.nvim', {'branch': 'release'}
  " Vim Dev Icons
  Plug 'kyazdani42/nvim-web-devicons'
  Plug 'ryanoasis/vim-devicons'
  " Status Line
  " Plug 'vim-airline/vim-airline'
  " Plug 'vim-airline/vim-airline-themes'
  Plug 'glepnir/galaxyline.nvim'
  " Follow Project Root Directory
  Plug 'airblade/vim-rooter'
  " Better tabline
  Plug 'romgrk/barbar.nvim'
  " Git
  Plug 'mhinz/vim-signify'
  Plug 'tpope/vim-fugitive'
  Plug 'tpope/vim-rhubarb'
  Plug 'junegunn/gv.vim'
  Plug 'rhysd/git-messenger.vim'
  Plug 'stsewd/fzf-checkout.vim'
  Plug 'f-person/git-blame.nvim'
  " Swap Windows
  Plug 'wesQ3/vim-windowswap'
  " Start Screen
  Plug 'mhinz/vim-startify'
  " Close buffer without closing nvim
  Plug 'moll/vim-bbye'
  " Markdown Preview
  Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app & npm install'  }
  " Surround
  Plug 'tpope/vim-surround'
  " highlight all matches under cursor
  Plug 'RRethy/vim-illuminate'
  " Better whitespace
  Plug 'ntpeters/vim-better-whitespace'
  " Auto change html tags
  Plug 'AndrewRadev/tagalong.vim'
  " Json comments
  Plug 'neoclide/jsonc.vim'
  " Better align
  Plug 'junegunn/vim-easy-align'

  " Laravel
  Plug 'jwalton512/vim-blade'

  " Better Syntax highlighting
  Plug 'nvim-treesitter/nvim-treesitter'
  Plug 'nvim-treesitter/playground'

  " Easily Create Gists
  Plug 'mattn/vim-gist'
  Plug 'mattn/webapi-vim'

  " Auto Indent
  Plug 'tpope/vim-sleuth'

  " Themes
  Plug 'drewtempelmeyer/palenight.vim'
  Plug 'sainnhe/sonokai'

  " Colorizer
  Plug 'norcalli/nvim-colorizer.lua'
  " Bracket Colorizer
  Plug 'junegunn/rainbow_parentheses.vim'

  " Telescope
  Plug 'nvim-lua/popup.nvim'
  Plug 'nvim-lua/plenary.nvim'
  Plug 'nvim-telescope/telescope.nvim'
  Plug 'nvim-telescope/telescope-media-files.nvim'
  Plug 'nvim-telescope/telescope-fzy-native.nvim'

  Plug 'kdheepak/lazygit.nvim'
endif

call plug#end()

" Automatically install missing plugins on startup
autocmd VimEnter *
  \  if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \|   PlugInstall --sync | q
  \| endif
