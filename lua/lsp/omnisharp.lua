local lspconfig = require('lspconfig')

vim.lsp.config.omnisharp = {
  cmd = { "omnisharp", "--languageserver", "--hostPID", tostring(vim.fn.getpid()) },
  root_dir = lspconfig.util.root_pattern("*.sln", "*.csproj", ".git"),
}

vim.api.nvim_create_augroup("sln_filetype", { clear = true })
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*.sln",
  callback = function()
    vim.bo.filetype = "cs"
  end,
})
