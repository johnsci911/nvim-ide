require'lspconfig'.clangd.setup{
  cmd = {
    "clangd"
  },
  filetypes = {
    "c",
    "cpp",
    "objc",
    "objcpp",
    "cuda",
    "proto"
  },
}
