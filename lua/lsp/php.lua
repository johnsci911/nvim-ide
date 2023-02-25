require'lspconfig'.intelephense.setup {
  cmd = { DATA_PATH .. "/mason/packages/intelephense/node_modules/.bin/intelephense", "--stdio" },
  filetypes = { "php" },
  root_pattern = {'composer.json', '.git'},
  settings = {
    intelephense = {
      files = {
      --   maxSize = 1000000;
      },
      environment = {
        includePaths = {
          -- "/home/serii/Sites/wordpress",
          -- "/home/serii/Sites/advanced-custom-fields-pro",
          -- "/home/serii/Sites/woocommerce"
        }
      }
    }
  }
}
