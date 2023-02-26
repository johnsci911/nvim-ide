require'lspconfig'.marksman.setup{
  cmd = {
    "marksman", "server"
  },
  filetypes = {
    "markdown",
  },
  single_file_support = true
}
