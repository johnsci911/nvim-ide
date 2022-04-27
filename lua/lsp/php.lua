require'lspconfig'.intelephense.setup {
    cmd = { DATA_PATH .. "/lsp_servers/php/node_modules/.bin/intelephense", "--stdio" },
	filetypes = { "php" }
}
