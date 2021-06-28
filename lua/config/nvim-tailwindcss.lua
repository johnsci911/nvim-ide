require'lspconfig'.tailwindcss.setup{
	cmd = {
		"tailwindcss-language-server",
		"--stdio"
	},
	filetypes = {
		"blade",
		"django-html",
		"html",
		"vue"
	}
}
