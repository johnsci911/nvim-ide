-- npm install -g yaml-language-server
require'lspconfig'.yamlls.setup{
  cmd = {DATA_PATH .. "/mason/packages/yaml-language-server/node_modules/.bin/yaml-language-server", "--stdio"},
}
