local M = {}

function M.nvim_tree_callback(callback_name)
    return string.format(":lua require'nvim-tree'.on_keypress('%s')<CR>", callback_name)
end

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
    -- closes neovim automatically when the tree is the last **WINDOW** in the view
    auto_close          = true,
    -- opens the tree when changing/opening a new tab if the tree wasn't previously opened
    open_on_tab         = false,
    -- hijack the cursor in the tree to put it at the start of the filename
    hijack_cursor       = false,
    -- updates the root directory of the tree on `DirChanged` (when your run `:cd` usually)
    update_cwd          = false,
    -- show lsp diagnostics in the signcolumn
    lsp_diagnostics     = true,
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

    view = {
        -- width of the window, can be either a number (columns) or a string in `%`
        width = 30,
        -- side of the tree, can be one of 'left' | 'right' | 'top' | 'bottom'
        side = 'left',
        -- if true the tree will resize itself after opening a file
        auto_resize = false,
        mappings = {
            -- custom only false will merge the list with the default mappings
            -- if true, it will only use your list to set the mappings
            custom_only = false,
            -- list of mappings to set on the tree manually
            list = {
                { key = {"<CR>", "o", "<2-LeftMouse>"}, cb = M.nvim_tree_callback("edit") },
                { key = {"<CR>"}, cb = M.nvim_tree_callback("edit") },
                { key = {"o"}, cb = M.nvim_tree_callback("edit") },
                { key = {"l"}, cb = M.nvim_tree_callback("edit") },
                { key = {"<2-LeftMouse>"}, cb  = M.nvim_tree_callback("edit") },
                { key = {"<2-RightMouse>"}, cb = M.nvim_tree_callback("cd") },
                { key = {"<C-]>"}, cb = M.nvim_tree_callback("cd") },
                { key = {"<C-v>"}, cb = M.nvim_tree_callback("vsplit") },
                { key = {"<C-x>"}, cb = M.nvim_tree_callback("split") },
                { key = {"<C-t>"}, cb = M.nvim_tree_callback("tabnew") },
                { key = {"<"}, cb = M.nvim_tree_callback("prev_sibling") },
                { key = {">"}, cb = M.nvim_tree_callback("next_sibling") },
                { key = {"<BS>"}, cb = M.nvim_tree_callback("close_node") },
                { key = {"h"}, cb = M.nvim_tree_callback("close_node") },
                { key = {"<S-CR>"}, cb = M.nvim_tree_callback("close_node") },
                { key = {"<Tab>"}, cb = M.nvim_tree_callback("preview") },
                { key = {"I"}, cb = M.nvim_tree_callback("toggle_ignored") },
                { key = {"H"}, cb = M.nvim_tree_callback("toggle_dotfiles") },
                { key = {"R"}, cb = M.nvim_tree_callback("refresh") },
                { key = {"a"}, cb = M.nvim_tree_callback("create") },
                { key = {"d"}, cb = M.nvim_tree_callback("remove") },
                { key = {"r"}, cb = M.nvim_tree_callback("rename") },
                { key = {"<C-r>"}, cb = M.nvim_tree_callback("full_rename") },
                { key = {"x"}, cb = M.nvim_tree_callback("cut") },
                { key = {"c"}, cb = M.nvim_tree_callback("copy") },
                { key = {"p"}, cb = M.nvim_tree_callback("paste") },
                { key = {"[c"}, cb = M.nvim_tree_callback("prev_git_item") },
                { key = {"]c"}, cb = M.nvim_tree_callback("next_git_item") },
                { key = {"-"}, cb = M.nvim_tree_callback("dir_up") },
                { key = {"q"}, cb = M.nvim_tree_callback("close") },
            }
        }
    }
}

