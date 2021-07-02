--[[ " 
--let g:nvim_tree_auto_ignore_ft = 'startify' "empty by default, don't auto open tree on specific filetypes.
let g:nvim_tree_hide_dotfiles = 1 "0 by default, this option hides files and folders starting with a dot `.`
let g:nvim_tree_git_hl = 1 "0 by default, will enable file highlight for git attributes (can be used without the icons).
" let g:nvim_tree_tab_open = 1 "0 by default, will open the tree when entering a new tab and the tree was previously open
" let g:nvim_tree_width_allow_resize  = 1 "0 by default, will not resize the tree when opening a file
let g:nvim_tree_show_icons = {
    \ 'git': 1,
    \ 'folders': 1,
    \ 'files': 1,
    \ }
"If 0, do not show the icons for one of 'git' 'folder' and 'files'
"1 by default, notice that if 'files' is 1, it will only display
"if nvim-web-devicons is installed and on your runtimepath ]] -- vim.g.nvim_tree_ignore = [ '.git', 'node_modules', '.cache' ] "empty by default
vim.g.nvim_tree_disable_netrw = 0 -- "1 by default, disables netrw
-- vim.g.nvim_tree_hijack_netrw = 0 --"1 by default, prevents netrw from automatically opening when opening directories (but lets you keep its other utilities)
vim.g.nvim_tree_hide_dotfiles = 0 -- 0 by default, this option hides files and folders starting with a dot `.`
vim.g.nvim_tree_indent_markers = 1 -- "0 by default, this option shows indent markers when folders are open
vim.g.nvim_tree_follow = 1 -- "0 by default, this option allows the cursor to be updated when entering a buffer
vim.g.nvim_tree_auto_close = 0 -- 0 by default, closes the tree when it's the last window
vim.g.nvim_tree_auto_ignore_ft = 'startify' --empty by default, don't auto open tree on specific filetypes.
local tree_cb = require'nvim-tree.config'.nvim_tree_callback
    vim.g.nvim_tree_bindings = {
      -- ["<CR>"] = ":YourVimFunction()<cr>",
      -- ["u"] = ":lua require'some_module'.some_function()<cr>",

      -- default mappings
      { key = {"<CR>", "o", "<2-LeftMouse>"}, cb = tree_cb("edit") },

      { key = {"<CR>"}, cb = tree_cb("edit") },
      { key = {"o"}, cb = tree_cb("edit") },
      { key = {"l"}, cb = tree_cb("edit") },
      { key = {"<2-LeftMouse>"}, cb  = tree_cb("edit") },
      { key = {"<2-RightMouse>"}, cb = tree_cb("cd") },
      { key = {"<C-]>"}, cb = tree_cb("cd") },
      { key = {"<C-v>"}, cb = tree_cb("vsplit") },
      { key = {"<C-x>"}, cb = tree_cb("split") },
      { key = {"<C-t>"}, cb = tree_cb("tabnew") },
      { key = {"<"}, cb = tree_cb("prev_sibling") },
      { key = {">"}, cb = tree_cb("next_sibling") },
      { key = {"<BS>"}, cb = tree_cb("close_node") },
      { key = {"h"}, cb = tree_cb("close_node") },
      { key = {"<S-CR>"}, cb = tree_cb("close_node") },
      { key = {"<Tab>"}, cb = tree_cb("preview") },
      { key = {"I"}, cb = tree_cb("toggle_ignored") },
      { key = {"H"}, cb = tree_cb("toggle_dotfiles") },
      { key = {"R"}, cb = tree_cb("refresh") },
      { key = {"a"}, cb = tree_cb("create") },
      { key = {"d"}, cb = tree_cb("remove") },
      { key = {"r"}, cb = tree_cb("rename") },
      { key = {"<C-r>"}, cb = tree_cb("full_rename") },
      { key = {"x"}, cb = tree_cb("cut") },
      { key = {"c"}, cb = tree_cb("copy") },
      { key = {"p"}, cb = tree_cb("paste") },
      { key = {"[c"}, cb = tree_cb("prev_git_item") },
      { key = {"]c"}, cb = tree_cb("next_git_item") },
      { key = {"-"}, cb = tree_cb("dir_up") },
      { key = {"q"}, cb = tree_cb("close") },
    }
-- vim.g.nvim_tree_show_icons = {git = 1, folders = 1, files = 1}
vim.g.nvim_tree_icons = {
    default = '',
    symlink = '',
    git = {unstaged = "", staged = "✓", unmerged = "", renamed = "➜", untracked = ""},
    folder = {default = "", open = "", empty = "", empty_open = "", symlink = ""}
}
