require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = {
      'bashls',
      'pyright',
      'intelephense,',
      'cssls',
      'jsonls',
      'vimls',
      'vuels',
      'tsserver',
      'jsonls',
      'html',
      'emmet_ls',
      'yamlls',
      'dockerls',
      'tailwindcss',
      'stylelint_lsp',
      'omnisharp',
      'graphql',
      'eslint',
      'lua_ls'
    },
    automatic_installation = true,
})

