O = {
    treesitter = {
        ensure_installed = "all",
        ignore_install   = {},
        highlight        = {enabled = true},
        playground       = {enabled = true},
        rainbow          = {enabled = false}
    }
}

DATA_PATH   = vim.fn.stdpath('data')
CACHE_PATH  = vim.fn.stdpath('cache')
CONFIG_PATH = vim.fn.stdpath('config')
