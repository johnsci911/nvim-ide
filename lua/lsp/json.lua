-- npm install -g vscode-json-languageserver
require'lspconfig'.jsonls.setup {
  cmd = {
    DATA_PATH .. "/mason/packages/json-lsp/node_modules/.bin/vscode-json-language-server",
    "--stdio"
  },
  filetypes = {
    "json",
    "jsonc"
  },
  init_options = {
    provideFormatter = true
  }
}
