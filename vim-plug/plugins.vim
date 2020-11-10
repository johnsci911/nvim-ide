" auto-install vim-plug
if empty(glob('~/.config/nvim/autoload/plug.vim'))
    silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    "autocmd VimEnter * PlugInstall
    autocmd VimEnter * PlugInstall | source $MYVIMRC
endif

call plug#begin('~/.config/nvim/autoload/plugged')

    " Better Syntax Support
    Plug 'sheerun/vim-polyglot'
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
    Plug 'junegunn/fzf.vim'
    Plug 'airblade/vim-rooter'
    " Better Comments
    Plug 'tpope/vim-commentary'
    " Ranger File Manager
    Plug 'kevinhwang91/rnvimr'
    " Intellisense
    Plug 'neoclide/coc.nvim', {'branch': 'release'}
    " Vim Dev Icons
    Plug 'ryanoasis/vim-devicons'
    " Follow Project Root Directory
    Plug 'airblade/vim-rooter'
    " Git
    Plug 'mhinz/vim-signify'
    Plug 'tpope/vim-fugitive'
    Plug 'tpope/vim-rhubarb'
    Plug 'junegunn/gv.vim'
    Plug 'rhysd/git-messenger.vim'
    Plug 'stsewd/fzf-checkout.vim'
    " Status Line
    Plug 'vim-airline/vim-airline'
    " Better tabline
    Plug 'mg979/vim-xtabline'
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

    " Themes
    Plug 'drewtempelmeyer/palenight.vim'

    " Colorizer
    Plug 'norcalli/nvim-colorizer.lua'
    " Bracket Colorizer
    Plug 'junegunn/rainbow_parentheses.vim'

call plug#end()

" Automatically install missing plugins on startup
autocmd VimEnter *
    \  if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
    \|   PlugInstall --sync | q
    \| endif
