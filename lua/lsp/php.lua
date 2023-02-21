require'lspconfig'.intelephense.setup {
  cmd = { DATA_PATH .. "/mason/packages/intelephense/node_modules/.bin/intelephense", "--stdio" },
    filetypes = { "php" },
    root_pattern = {'composer.json', '.git'}
}
