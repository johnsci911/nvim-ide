require('lspconfig').eslint.setup{
  cmd = { DATA_PATH .. "/lsp_servers/vscode-eslint/node_modules/.bin/vscode-eslint-language-server", "--stdio" },
  filetypes = {
    "javascript",
    "javascriptreact",
    "javascript.jsx",
    "typescript",
    "typescriptreact",
    "typescript.tsx",
    "vue",
    "svelte",
    "astro"
  },
  settings = {
    codeAction = {
      disableRuleComment = {
        enable = true,
      location = "separateLine"
      },
      showDocumentation = {
        enable = true
      }
    },
    codeActionOnSave = {
      enable = false,
      mode = "all"
    },
    format = true,
    nodePath = "",
    onIgnoredFiles = "off",
    packageManager = "npm",
    quiet = false,
    rulesCustomizations = {},
    run = "onType",
    useESLintClass = false,
    validate = "on",
    workingDirectory = {
      mode = "location"
    }
  }
}

