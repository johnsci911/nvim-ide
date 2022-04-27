-- npm install -g vscode-json-languageserver
require'lspconfig'.jsonls.setup {
    cmd = {
        DATA_PATH .. "/lsp_servers/jsonls/node_modules/.bin/vscode-json-language-server",
        "--stdio"
    },
    -- on_attach = require'lsp'.common_on_attach,
	filetypes = {
		"json",
		"jsonc"
	},
	init_options = {
		provideFormatter = true
	}
}
