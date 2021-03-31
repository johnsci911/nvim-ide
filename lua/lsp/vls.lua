-- set the path to the vls installation;
local vls_root_path = CACHE_PATH .. '/lspconfig/vls'
local vls_binary = vls_root_path.."/cmd/vls/vls"

require'lspconfig'.vls.setup {
  cmd = {vls_binary},
  on_attach = require'lsp'.common_on_attach
}
