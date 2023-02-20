-- Fix "No information avaiable" when hover
vim.lsp.handlers['textDocument/hover'] = function(_, result, ctx, config)
  config = config or {}
  config.focus_id = ctx.method
  if not (result and result.contents) then
    return
  end
  local markdown_lines = vim.lsp.util.convert_input_to_markdown_lines(result.contents)
  markdown_lines = vim.lsp.util.trim_empty_lines(markdown_lines)
  if vim.tbl_isempty(markdown_lines) then
    return
  end
  return vim.lsp.util.open_floating_preview(markdown_lines, 'markdown', config)
end

local navic = require("nvim-navic")

local on_attach = function(client, bufnr)
  local function buf_set_option(...)
      vim.api.nvim_buf_set_option(bufnr, ...)
  end

  if client.server_capabilities.documentSymbolProvider then
      navic.attach(client, bufnr)
  end

  buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

require("lspconfig").clangd.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  autostart = true,
  settings = {
    Lua = {
      diagnostics = {
        globals = {'vim'}
      }
    }
  }
}

