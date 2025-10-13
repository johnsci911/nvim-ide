-- npm install -g vscode-css-languageserver-bin
vim.lsp.config.cssls = {
  cmd = { "vscode-css-language-server", "--stdio" },
  filetypes = {
    "css", "scss", "less"
  }
}
