-- npm install -g vscode-css-languageserver-bin
require'lspconfig'.cssls.setup {
    cmd = {
        DATA_PATH .. "/lsp_servers/cssls/node_modules/.bin/vscode-css-language-server",
        "--stdio"
    },
}
