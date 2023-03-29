-- npm i -g pyright
require'lspconfig'.pyright.setup {
  cmd = { "pyright-langserver", "--stdio"},
  handlers = {
    ["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
      virtual_text = true, -- Move this function to make it accessible by all languages
      signs = true,
      underline = true,
      update_in_insert = true
    })
  }
}
