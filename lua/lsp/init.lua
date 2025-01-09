-- Custom handler for "hover" to fix "No information available" message
vim.lsp.handlers["textDocument/hover"] = function(_, result, ctx, config)
  config = config or {}
  config.focus_id = ctx.method

  if not (result and result.contents) then return end

  local markdown_lines = vim.lsp.util.convert_input_to_markdown_lines(result.contents)
  markdown_lines = vim.lsp.util.trim_empty_lines(markdown_lines)

  if vim.tbl_isempty(markdown_lines) then return end

  return vim.lsp.util.open_floating_preview(markdown_lines, "markdown", config)
end

-- Function to attach LSP features to a buffer
local function on_attach(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")
end

-- Autocommand to set up buffer-specific LSP mappings
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

    local opts = { buffer = ev.buf, noremap = true, silent = true }

    -- Key mappings for LSP functions
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set("n", "<space>wl", function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, opts)
    vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set({ "n", "v" }, "<space>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "<space>lf", function()
      vim.lsp.buf.format { async = true }
    end, { desc = "LSP format file" })
  end,
})

-- Enhanced LSP capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

-- List of LSP servers to configure
local servers = {
  "bashls",
  "clangd",
  "pyright",
  "intelephense",
  "cssls",
  "vimls",
  "ts_ls",
  "jsonls",
  "html",
  "emmet_ls",
  "yamlls",
  "dockerls",
  "tailwindcss",
  "graphql",
  "lua_ls",
  "volar",
  "eslint",
  "omnisharp",
  "taplo",
  "sqlls",
  "marksman",
}

-- Setup Mason for LSP management
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = servers,
  automatic_installation = true,
})

-- Configure LSP servers
local lspconfig = require("lspconfig")

for _, name in pairs(servers) do
  lspconfig[name].setup {
    on_attach = on_attach,
    capabilities = capabilities,
    autostart = true,
    underline = true,
    update_in_insert = false,
    virtual_text = {
      spacing = 2,
      source = "if_many",
      prefix = "●",
    },
    severity_sort = true,
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = " ",
        [vim.diagnostic.severity.WARN] = " ",
        [vim.diagnostic.severity.HINT] = " ",
        [vim.diagnostic.severity.INFO] = " ",
      },
    },
    settings = {
      Lua = {
        diagnostics = { globals = { "vim" } },
      },
    },
  }
end

-- Configure SourceKit for Swift manually
-- `brew install swift`
lspconfig.sourcekit.setup {
  cmd = { "xcrun", "sourcekit-lsp" },
  filetypes = { "swift", "objective-c", "objective-cpp" },
  root_dir = lspconfig.util.root_pattern(".git", "*.xcodeproj", "*.xcworkspace"),
}
