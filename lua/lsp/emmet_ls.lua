vim.lsp.config('emmet_ls', {
  cmd = { 'emmet-ls', '--stdio' },
  filetypes = { "astro", "css", "eruby", "html", "htmlangular", "htmldjango", "javascriptreact", "less", "pug", "sass", "scss", "svelte", "templ", "typescriptreact", "vue" },
  root_markers = { ".git", "package.json" },
})
