-- npm install -g yaml-language-server
vim.lsp.config.yamlls = {
  cmd = { "yaml-language-server", "--stdio" },
  settings = {
    yaml = {
      schemas = {
        ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
      },
    },
  }
}
