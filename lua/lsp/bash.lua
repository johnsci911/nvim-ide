-- npm i -g bash-language-server
require'lspconfig'.bashls.setup {
  cmd = {DATA_PATH .. "/lsp_servers/bash/node_modules/.bin/bash-language-server", "start"},
  filetypes = { "sh", "zsh" }
}
