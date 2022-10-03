-- npm install -g vscode-html-languageserver-bin
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

require'lspconfig'.html.setup {
    cmd = {DATA_PATH .. "/lsp_servers/html/node_modules/.bin/vscode-html-language-server", "--stdio"},
	filetypes = {
		"html",
		"blade",
	},
    capabilities = capabilities
}
