-- npm install -g vscode-json-languageserver
require'lspconfig'.jsonls.setup {
    cmd = {
        DATA_PATH .. "/lsp_servers/jsonls/node_modules/.bin/vscode-json-language-server",
        "--stdio"
    },
	filetypes = {
		"json",
		"jsonc"
	},
	init_options = {
		provideFormatter = true
	}
}
