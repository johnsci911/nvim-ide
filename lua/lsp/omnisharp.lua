local lspconfig = require('lspconfig')

lspconfig.omnisharp.setup {
  cmd = { "omnisharp", "--languageserver", "--hostPID", tostring(vim.fn.getpid()) },
  root_dir = lspconfig.util.root_pattern("*.sln", "*.csproj", ".git"),
}
