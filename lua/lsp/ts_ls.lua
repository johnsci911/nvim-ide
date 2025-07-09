local lspconfig = require("lspconfig")
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

local on_attach = function(client, bufnr)
  local opts = { buffer = bufnr, noremap = true, silent = true }
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
  vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
  vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
end

local npm_root = vim.fn.system("npm root -g"):gsub("%s+", "")
local vue_ts_plugin_path = npm_root .. "/@vue/typescript-plugin"

lspconfig.ts_ls.setup{
  on_init = function(client, _)
    client.config.init_options = client.config.init_options or {}
    client.config.init_options.plugins = {
      {
        name = "@vue/typescript-plugin",
        location = vue_ts_plugin_path,
        languages = { "javascript", "typescript", "vue" },
      },
    }
    client.config.init_options.typescript = {
      preferences = {
        importModuleSpecifierPreference = "relative",
        includeCompletionsForModuleExports = true,
        includeCompletionsWithInsertText = true,
        quotePreference = "auto",
        allowTextChangesInNewFiles = true,
        providePrefixAndSuffixTextForRename = true,
        allowRenameOfImportPath = true,
        provideRefactorNotApplicableReason = true,
        includeAutomaticOptionalChainCompletions = true,
        includeCompletionsForImportStatements = true,
        includeCompletionsWithSnippetText = true,
        completeFunctionCalls = true,
      },
    }
    client.config.init_options.javascript = client.config.init_options.typescript
    client.notify("workspace/didChangeConfiguration", { settings = client.config.init_options })
  end,
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "javascript", "typescript", "vue" },
}

