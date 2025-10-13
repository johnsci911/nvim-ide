vim.lsp.config.intelephense = {
  cmd = { "intelephense", "--stdio" },
  filetypes = { "php" },
  root_pattern = { 'composer.json', '.git' },
}
