vim.lsp.config('vue_ls', {
  cmd = {
    "vue-language-server", "--stdio"
  },
  -- add filetypes for typescript, javascript and vue
  filetypes = {
    'typescript',
    'javascript',
    'javascriptreact',
    'typescriptreact',
    'vue'
  },
  init_options = {
    vue = {
      -- disable hybrid mode
      hybridMode = true,
    },
  },
})
