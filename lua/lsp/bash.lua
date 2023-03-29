-- npm i -g bash-language-server
require'lspconfig'.bashls.setup {
  cmd = {
    "bash-language-server",
    "start"
  },
  filetypes = { "sh", "zsh" }
}
