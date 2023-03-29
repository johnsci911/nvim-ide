require'lspconfig'.intelephense.setup {
  cmd = { "intelephense", "--stdio" },
  filetypes = { "php" },
  root_pattern = {'composer.json', '.git'},
}
