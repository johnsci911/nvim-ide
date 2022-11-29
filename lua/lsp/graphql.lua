require'lspconfig'.graphql.setup{
  cmd = {
    "graphql-lsp",
    "server",
    "-m",
    "stream"
  },
  filetypes = {
    "graphql",
    "typescriptreact",
    "javascriptreact",
  },
}
