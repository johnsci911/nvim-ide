require'lspconfig'.intelephense.setup {
    cmd = { DATA_PATH .. "/lspinstall/php/node_modules/.bin/intelephense", "--stdio" },
    on_attach = require'lsp'.common_on_attach,

	-- This doesn't work
	defaule_config = {
		init_options = {
			licenceKey = "intelephense"
		}
	}
}
