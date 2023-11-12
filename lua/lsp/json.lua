--Enable (broadcasting) snippet capability for completion
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

-- npm install -g vscode-json-languageserver
require'lspconfig'.jsonls.setup {
  capabilities = capabilities,
  cmd = { "vscode-json-language-server", "--stdio" },
  filetypes = {
    "json",
    "jsonc"
  },
  init_options = {
    provideFormatter = true
  }
}
