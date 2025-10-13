-- npm i -g bash-language-server
vim.lsp.config.bashls = {
  cmd = {
    "bash-language-server",
    "start"
  },
  filetypes = { "sh", "zsh" }
}
