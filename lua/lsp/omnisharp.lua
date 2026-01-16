-- OmniSharp configuration using modern vim.lsp.config API
vim.lsp.config.omnisharp = {
  cmd = { "omnisharp", "--languageserver", "--hostPID", tostring(vim.fn.getpid()) },
  filetypes = { "cs" },
  root_dir = vim.fs.root(0, { "*.sln", "*.csproj", ".git" }),
}

-- Treat .sln files as C# for syntax highlighting
vim.api.nvim_create_augroup("sln_filetype", { clear = true })
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*.sln",
  callback = function()
    vim.bo.filetype = "cs"
  end,
})
