local actions = require('telescope.actions')
-- Global remapping
------------------------------
-- '--color=never',
require('telescope').load_extension('media_files')
require('telescope').load_extension('project')
require('telescope').load_extension('fzf')
require('telescope').load_extension('session-lens')
require('telescope').load_extension('glyph')
require('telescope').load_extension('notify')

require('telescope').setup {
    defaults = {
        vimgrep_arguments = {
            'rg',
            '--no-heading',
            '--with-filename',
            '--line-number',
            '--column',
            '--smart-case',
        },
        prompt_prefix = " ",
        selection_caret = " ",
        entry_prefix = "  ",
        initial_mode = "insert",
        selection_strategy = "reset",
        sorting_strategy = "ascending",
        layout_strategy = "horizontal",
        layout_config = {
            prompt_position = "top",
            horizontal = {mirror = false}, vertical = {mirror = false},
            width = 0.75,
            preview_cutoff = 120,
        },
        file_sorter = require'telescope.sorters'.get_fzy_sorter,
        file_ignore_patterns = {},
        path_display = {
            'shorten',
            'absolute'
        },
        winblend = 0,
        border = {},
        borderchars = {'─', '│', '─', '│', '╭', '╮', '╯', '╰'},
        color_devicons = true,
        use_less = true,
        set_env = {['COLORTERM'] = 'truecolor'}, -- default = nil,
        file_previewer = require'telescope.previewers'.vim_buffer_cat.new,
        grep_previewer = require'telescope.previewers'.vim_buffer_vimgrep.new,
        qflist_previewer = require'telescope.previewers'.vim_buffer_qflist.new,

        -- Developer configurations: Not meant for general override
        buffer_previewer_maker = require'telescope.previewers'.buffer_previewer_maker,
        mappings = {
            i = {
                -- ["<C-j>"] = actions.move_selection_next,
                -- ["<C-k>"] = actions.move_selection_previous,
                -- To disable a keymap, put [map] = false
                -- So, to not map "<C-n>", just put
                -- ["<c-x>"] = false,
                ["<esc>"] = actions.close,

                -- Otherwise, just set the mapping to the function that you want it to be.
                -- ["<C-i>"] = actions.select_horizontal,

                -- Add up multiple actions
                ["<CR>"] = actions.select_default + actions.center

                -- You can perform as many actions in a row as you like
                -- ["<CR>"] = actions.select_default + actions.center + my_cool_custom_action,
            },
            n = {
                -- ["<C-j>"] = actions.move_selection_next,
                -- ["<C-k>"] = actions.move_selection_previous
                -- ["<C-i>"] = my_cool_custom_action,
            }
        },
        extensions = {
            media_files = {
                filetypes = {"png", "webp", "jpg", "jpeg", "mp4", "pdf"},
                find_cmd = "rg"
            },
            fzf = {
                fuzzy = true,                    -- false will only do exact matching
                override_generic_sorter = false, -- override the generic sorter
                override_file_sorter = true,     -- override the file sorter
                case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
                                                 -- the default case_mode is "smart_case"
            },
            glyph = {
                action = function(glyph)
                    vim.fn.setreg("*", glyph.value)
                    print([[Press "*P to paste this glyph ]] .. glyph.value)
                end,
            },
        }
    }
}

require('session-lens').setup {
    path_display = {'shorten'},
    theme_conf = {
        border = true
    },
    previewer = true,
    prompt_title = "Search Sessions"
}
