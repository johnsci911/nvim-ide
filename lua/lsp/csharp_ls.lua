-- csharp_ls configuration using modern vim.lsp.config API
-- Note: Currently disabled due to broken NuGet package
vim.lsp.config.csharp_ls = {
  cmd = { "csharp-ls" },
  filetypes = { "cs" },
  root_dir = vim.fs.root(0, { "*.sln", "*.csproj", ".git" }),
}
