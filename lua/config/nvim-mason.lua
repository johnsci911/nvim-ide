require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = {
      'bashls',
      'pyright',
      'intelephense,',
      'sumneko_lua',
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
    },
    automatic_installation = true,
})

