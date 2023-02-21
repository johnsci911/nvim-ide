-- npm i -g bash-language-server
require'lspconfig'.bashls.setup {
  cmd = {DATA_PATH .. "/mason/packages/bash-language-server/node_modules/.bin/bash-language-server", "start"},
  filetypes = { "sh", "zsh" }
}
