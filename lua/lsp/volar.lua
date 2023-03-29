require'lspconfig'.volar.setup{
  cmd = { "vue-language-server", "--stdio"},
  filetypes = {
    'typescript',
    'javascript',
    'javascriptreact',
    'typescriptreact',
    'vue',
    'json'
  }
}
