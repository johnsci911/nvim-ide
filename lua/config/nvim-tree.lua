local tree_cb = require'nvim-tree.config'.nvim_tree_callback

-- following options are the default
require'nvim-tree'.setup {
    -- disables netrw completely
    disable_netrw       = false,
    -- hijack netrw window on startup
    hijack_netrw        = true,
    -- open the tree when running this setup function
    open_on_setup       = false,
    -- will not open on setup if the filetype is in this list
    ignore_ft_on_setup  = {},
    -- opens the tree when changing/opening a new tab if the tree wasn't previously opened
    open_on_tab         = false,
    -- hijack the cursor in the tree to put it at the start of the filename
    hijack_cursor       = false,
    -- updates the root directory of the tree on `DirChanged` (when your run `:cd` usually)
    update_cwd          = true,
    -- show lsp diagnostics in the signcolumn
    diagnostics = {
        enable = true,
    },
    -- update the focused file on `BufEnter`, un-collapses the folders recursively until it finds the file
    update_focused_file = {
        -- enables the feature
        enable      = true,
        -- update the root directory of the tree to the one of the folder containing the file if the file is not under the current root directory
        -- only relevant when `update_focused_file.enable` is true
        update_cwd  = true,
        -- list of buffer names / filetypes that will not update the cwd if the file isn't found under the current root directory
        -- only relevant when `update_focused_file.update_cwd` is true and `update_focused_file.enable` is true
        ignore_list = {}
    },
    -- configuration options for the system open command (`s` in the tree by default)
    system_open = {
        -- the command to run this, leaving nil should work in most cases
        cmd  = nil,
        -- the command arguments as a list
        args = {}
    },
    git = {
        enable  = true,
        ignore  = true,
        timeout = 500,
    },
    view = {
        -- width of the window, can be either a number (columns) or a string in `%`
        width = 30,
        -- side of the tree, can be one of 'left' | 'right' | 'top' | 'bottom'
        side = 'left',
        mappings = {
            -- custom only false will merge the list with the default mappings
            -- if true, it will only use your list to set the mappings
            custom_only = false,
            -- list of mappings to set on the tree manually
            list = {
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
        }
    }
}

