-- npm install -g vim-language-server
require'lspconfig'.vimls.setup {
  cmd = { "vim-language-server", "--stdio" },
}
