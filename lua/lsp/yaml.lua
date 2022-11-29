-- npm install -g yaml-language-server
require'lspconfig'.yamlls.setup{
  cmd = {DATA_PATH .. "/lsp_servers/yaml/node_modules/.bin/yaml-language-server", "--stdio"},
}
