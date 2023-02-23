require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = {
      'bashls',
      'pyright',
      'intelephense,',
      'cssls',
      'jsonls',
      'vimls',
      'tsserver',
      'jsonls',
      'html',
      'emmet_ls',
      'yamlls',
      'dockerls',
      'tailwindcss',
      'omnisharp',
      'graphql',
      'lua_ls',
      'volar',
      -- 'eslint',
    },
    automatic_installation = true,
})

