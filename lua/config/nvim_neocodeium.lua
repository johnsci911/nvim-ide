-- NeoCodeium Configuration
require("neocodeium").setup({
  -- Accepts boolean or function. If it is boolean and false, then neocodeium disabled at
  -- startup, until it is enabled manually. When it is function, it has one argument
  -- `bufnr` and should return boolean. With it, you can implement your own logic to disable
  -- neocodeium for your requirements.
  enabled = true,
  -- Path to a custom Codeium server binary (you can download one from:
  -- https://github.com/Exafunction/codeium/releases)
  bin = nil,
  -- When set to `true`, autosuggestions are disabled.
  -- Use `require'neodecodeium'.cycle_or_complete()` to show suggestions manually
  manual = false,
  -- Information about the API server to use
  server = {
    -- API URL to use (for Enterprise mode)
    api_url = nil,
    -- Portal URL to use (for registering a user and downloading the binary)
    portal_url = nil,
  },
  -- Set to `false` to disable showing the number of suggestions label
  -- at the line column
  show_label = true,
  -- Set to `true` to enable suggestions debounce
  debounce = false,
  -- Maximum number of lines parsed from loaded buffers (current buffer always fully parsed)
  -- Set to `0` to disable parsing non-current buffers (may lower suggestion quality)
  -- Set it to `-1` to parse all lines
  max_lines = 10000,
  -- Set to `true` to disable some non-important messages, like "NeoCodeium: server started..."
  silent = false,
  -- Set to `false` to disable suggestions in buffers with specific filetypes
  filetypes = {
    help = false,
    gitcommit = false,
    gitrebase = false,
    ["."] = false,
  },
  -- List of directories and files to detect workspace root directory for codeium chat
  root_dir = { ".bzr", ".git", ".hg", ".svn", "_FOSSIL_", "package.json" }
})
