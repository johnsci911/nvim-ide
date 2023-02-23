require'lspconfig'.volar.setup{
  cmd = {
    DATA_PATH .. "/mason/packages/vue-language-server/node_modules/.bin/vue-language-server",
    "--stdio,"
  },
  filetypes = {
    'typescript',
    'javascript',
    'javascriptreact',
    'typescriptreact',
    'vue',
    'json'
  }
}
