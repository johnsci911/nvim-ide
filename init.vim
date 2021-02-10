" Settings
source $HOME/.config/nvim/vim-plug/plugins.vim
source $HOME/.config/nvim/keys/keybindings.vim

if exists('g:vscode')
  source $HOME/.config/nvim/vscode/settings.vim
  source $HOME/.config/nvim/plug-config/easymotion.vim
  source $HOME/.config/nvim/plug-config/highlightyank.vim
else

  source $HOME/.config/nvim/general/settings.vim

  " Plugin Configurations
  source $HOME/.config/nvim/keys/which-key.vim
  source $HOME/.config/nvim/plug-config/quickscope.vim
  source $HOME/.config/nvim/plug-config/floaterm.vim
  source $HOME/.config/nvim/plug-config/fzf.vim
  source $HOME/.config/nvim/plug-config/rainbow.vim
  source $HOME/.config/nvim/plug-config/vim-commentary.vim
  source $HOME/.config/nvim/plug-config/rnvimr.vim
  source $HOME/.config/nvim/plug-config/coc.vim
  source $HOME/.config/nvim/plug-config/vim-rooter.vim
  source $HOME/.config/nvim/plug-config/startify.vim
  source $HOME/.config/nvim/plug-config/gitgutter.vim
  source $HOME/.config/nvim/plug-config/git-messenger.vim
  source $HOME/.config/nvim/plug-config/window-swap.vim
  source $HOME/.config/nvim/plug-config/Bufonly.vim
  source $HOME/.config/nvim/plug-config/illuminate.vim
  source $HOME/.config/nvim/plug-config/better-whitespace.vim
  source $HOME/.config/nvim/plug-config/tagalong.vim
  source $HOME/.config/nvim/plug-config/easy-align.vim

  " Themes
  source $HOME/.config/nvim/themes/termguicolors.vim
  source $HOME/.config/nvim/themes/airline.vim
  " source $HOME/.config/nvim/themes/palenight.vim

  " Custom Theme -- Comment if you're not using custom theme
  source $HOME/.config/nvim/themes/gruvbox-custom.vim

  " Lua Plugin Configurations
  " source $HOME/.config/nvim/themes/termguicolors.vim
  " source $HOME/.config/nvim/themes/sonokai.vim

  " Custom Theme -- Comment if you're not using custom theme
  " source $HOME/.config/nvim/themes/gruvbox-custom.vim

  " Lua Plugin Configurations
  " luafile $HOME/.config/nvim/lua/treesitter.lua
  luafile $HOME/.config/nvim/lua/plug-colorizer.lua
  luafile $HOME/.config/nvim/lua/galaxy.lua

  " Transparency
    " highlight Normal guibg=none
    " highlight NonText guibg=none
endif
