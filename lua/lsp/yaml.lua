-- npm install -g yaml-language-server
require 'lspconfig'.yamlls.setup {
  cmd = { "yaml-language-server", "--stdio" },
  settings = {
    yaml = {
      schemas = {
        ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
      },
    },
  }
}
