-- npm install -g vscode-css-languageserver-bin
require'lspconfig'.cssls.setup {
  cmd = { "vscode-css-language-server", "--stdio" },
  filetypes = {
    "css", "scss", "less"
  }
}

