local lspconfig = require('lspconfig')

-- lspconfig.tsserver.setup {}
lspconfig.volar.setup {
  filetypes = {
    'typescript',
    'javascript',
    'javascriptreact',
    'typescriptreact',
    'vue'
  },
  init_options = {
    vue = {
      hybridMode = false,
    },
  },
}
