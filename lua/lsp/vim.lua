-- npm install -g vim-language-server
require'lspconfig'.vimls.setup {
  cmd = {DATA_PATH .. "/mason/packages/vim-language-server/node_modules/.bin/vim-language-server", "--stdio"},
}
