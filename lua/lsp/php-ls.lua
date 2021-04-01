require'lspconfig'.intelephense.setup {
	cmd = { DATA_PATH .. "/lspinstall/php/node_modules/.bin/intelephense", "--stdio" },
	default_config = {
		init_options = {
			-- licenceKey = require('intelephense')
		}
	},
    on_attach = require'lsp'.common_on_attach
}
