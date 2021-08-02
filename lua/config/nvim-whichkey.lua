local wk = require("which-key")

wk.setup {
    plugins = {
        marks = true, -- shows a list of your marks on ' and `
        registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
        -- the presets plugin, adds help for a bunch of default keybindings in Neovim
        -- No actual key bindings are created
        spelling = {
            enabled = false, -- enabling this will show WhichKey when pressing z= to select spelling suggestions
            suggestions = 20, -- how many suggestions should be shown in the list?
        },
        presets = {
            operators = true, -- adds help for operators like d, y, ... and registers them for motion / text object completion
            motions = true, -- adds help for motions
            text_objects = true, -- help for text objects triggered after entering an operator
            windows = true, -- default bindings on <c-w>
            nav = true, -- misc bindings to work with windows
            z = true, -- bindings for folds, spelling and others prefixed with z
            g = true, -- bindings for prefixed with g
        },
    },
    -- add operators that will trigger motion and text object completion
    -- to enable all native operators, set the preset / operators plugin above
    operators = { gc = "Comments" },
    key_labels = {
        -- override the label used to display some keys. It doesn't effect WK in any other way.
        -- For example:
        -- ["<space>"] = "SPC",
        -- ["<cr>"] = "RET",
        -- ["<tab>"] = "TAB",
    },
    icons = {
        breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
        separator = "➜", -- symbol used between a key and it's label
        group = "+", -- symbol prepended to a group
    },
    window = {
        border = "none", -- none, single, double, shadow
        position = "bottom", -- bottom, top
        margin = { 1, 0, 1, 0 }, -- extra window margin [top, right, bottom, left]
        padding = { 2, 2, 2, 2 }, -- extra window padding [top, right, bottom, left]
    },
    layout = {
        height = { min = 4, max = 25 }, -- min and max height of the columns
        width = { min = 20, max = 50 }, -- min and max width of the columns
        spacing = 3, -- spacing between columns
        align = "left", -- align columns left, center or right
    },
    ignore_missing = false, -- enable this to hide mappings for which you didn't specify a label
    hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ "}, -- hide mapping boilerplate
    show_help = true, -- show help message on the command line when the popup is visible
    triggers = "auto", -- automatically setup triggers
    -- triggers = {"<leader>"} -- or specify a list manually
    triggers_blacklist = {
        -- list of mode / prefixes that should never be hooked by WhichKey
        -- this is mostly relevant for key maps that start with a native binding
        -- most people should not need to change this
        -- i = { "j", "k" },
        -- v = { "j", "k" },
    },
}

wk.register({
    ['/'] = {'<Cmd>CommentToggle<CR>'                                                  , 'comment line'},
    ['.'] = {'<Cmd>e $MYVIMRC<CR>'                                                     , 'My VIMRC'},
    [';'] = {'<Cmd>Commands<CR>'                                                       , 'Show commands'},
    ['='] = {'<C-W>='                                                                  , 'Balance windows'},
    ['d'] = {'<Cmd>BufferClose<CR>'                                                    , 'Close buffer'},
    ['?'] = {'<Cmd>NvimTreeFindFile<CR>'                                               , 'Reveal current file'},
    ['e'] = {'<Cmd>NvimTreeToggle<CR>'                                                 , 'Toggle Explorer'},
    ['E'] = {'<Cmd>NvimTreeRefresh<CR>'                                                , 'Refresh Explorer'},
    ['r'] = {'<Cmd>Telescope file_browser<CR>'                                         , 'File Browser'},
    ['R'] = {'<Cmd>Telescope file_browser theme=get_dropdown<CR>'                      , 'Small File Browser'},
    ['f'] = {'<Cmd>Telescope current_buffer_fuzzy_find<CR>'                            , 'Fuzzy find current buffer'},
    ['h'] = {'<C-W>s'                                                                  , 'Split Vertical'},
    ['v'] = {'<C-W>v'                                                                  , 'Split Horizontal'},
    ['W'] = {'w'                                                                       , 'Write'},
    ['m'] = {'<Cmd>call WindowSwap#EasyWindowSwap()<CR>'                               , 'Swap Window'},
    ['q'] = {'<Cmd>q<CR>'                                                              , 'quit'},
    ['T'] = {'<Cmd>set expandtab<CR> | <Cmd>retab<CR>'                                 , 'Convert tab to space'},
    [','] = {
        name  = '+emmet',
        [';'] = {':call emmet#expandAbbr(1,"")<cr>' , 'expand word'},
        [','] = {':call emmet#expandAbbr(3,"")<cr>' , 'expand abbr'},
        ['/'] = {':call emmet#toggleComment()<cr>'  , 'toggle comment'},
        u     = {':call emmet#updateTag()<cr>'      , 'update tag'},
        d     = {':call emmet#balanceTag(1)<cr>'    , 'balance tag in'},
        D     = {':call emmet#balanceTag(-1)<cr>'   , 'balance tag out'},
        n     = {':call emmet#moveNextPrev(0)<cr>'  , 'move next'},
        N     = {':call emmet#moveNextPrev(1)<cr>'  , 'move prev'},
        i     = {':call emmet#imageSize()<cr>'      , 'image size'},
        j     = {':call emmet#splitJoinTag()<cr>'   , 'split join tag'},
        k     = {':call emmet#removeTag()<cr>'      , 'remove tag'},
        a     = {':call emmet#anchorizeURL(0)<cr>'  , 'anchorize url'},
        A     = {':call emmet#anchorizeURL(1)<cr>'  ,'anchorize summary'},
        m     = {':call emmet#mergeLines()<cr>'     , 'merge lines'},
        c     = {':call emmet#codePretty()<cr>'     , 'code pretty'},
        t     = {'<Cmd>TSBufDisable<CR>'            , 'Treesitter disable current buffer'},
        T     = {'<Cmd>TSBufEnable<CR>'             , 'Treesitter enable current buffer'}
    },
    a = {
        name = '+actions'                        ,
        c    = {'<Cmd>ColorizerToggle<CR>'       , 'Bracket Colorizer'},
        s    = {'<Cmd>let @/ = ""<CR>'           , 'Remove search highlight'},
        w    = {'<Cmd>StripWhitespace<CR>'       , 'Strip whitespace'},
        m    = {'<Cmd>MarkdownPreviewToggle<CR>' , 'Markdown preview'},
    },
    b = {
        name = '+buffers',
        d    = {'<Cmd>BufferClose<CR>'              , 'Close Buffer'},
        D    = {'<Cmd>BufferCloseAllButCurrent<CR>' , 'Close all but current'},
        s    = {'<Cmd>Dashboard<CR>'                , 'Dashboard'},
        p    = {'<Cmd>BufferPick<CR>'               , 'Pick buffer'},
        h    = {'<Cmd>BufferMovePrevious<CR>'       , 'Buffer move left'},
        l    = {'<Cmd>BufferMoveNext<CR>'           , 'Buffer move right'},
        b    = {'<Cmd>BufferOrderByDirectory<CR>'   , 'Buffer order by directory'},
        L    = {'<Cmd>BufferCloseBuffersRight<CR>'  , 'Close buffers on right'},
        H    = {'<Cmd>BufferCloseBuffersRight<CR>'  , 'Close buffers on left'},
    },
    D = {
        name = '+debug' ,
        b    = {'<Cmd>DebugToggleBreakpoint<CR>' , 'toggle breakpoint'},
        c    = {'<Cmd>DebugContinue<CR>'         , 'continue'},
        i    = {'<Cmd>DebugStepInto<CR>'         , 'step into'},
        o    = {'<Cmd>DebugStepOver<CR>'         , 'step over'},
        r    = {'<Cmd>DebugToggleRepl<CR>'       , 'toggle repl'},
        s    = {'<Cmd>DebugStart<CR>'            , 'start'},
    },
    F = {
    name = '+fold',
        ['O'] = {'<Cmd>set foldlevel=20<CR>' , 'open all'},
        ['C'] = {'<Cmd>set foldlevel=0<CR>'  , 'close all'},
        ['c'] = {'<Cmd>foldclose<CR>'        , 'close'},
        ['o'] = {'<Cmd>foldopen<CR>'         , 'open'},
        ['1'] = {'<Cmd>set foldlevel=1<CR>'  , 'level1'},
        ['2'] = {'<Cmd>set foldlevel=2<CR>'  , 'level2'},
        ['3'] = {'<Cmd>set foldlevel=3<CR>'  , 'level3'},
        ['4'] = {'<Cmd>set foldlevel=4<CR>'  , 'level4'},
        ['5'] = {'<Cmd>set foldlevel=5<CR>'  , 'level5'},
        ['6'] = {'<Cmd>set foldlevel=6<CR>'  , 'level6'}
    },
	['p'] = {
		name = 'Project wide search',
		['P'] = {'<Cmd>Telescope project<CR>'                                              , 'Search Project'},
		['p'] = {'<Cmd>Telescope find_files find_command=rg,--ignore,--hidden,--files<CR>' , 'search files'},

	},
    s = {
        name  = '+search',
        b     = {'<Cmd>Telescope buffers<CR>'                   , 'Buffers'},
        ['.'] = {'<Cmd>Telescope filetypes<CR>'                 , 'filetypes'},
        d     = {'<Cmd>Telescope lsp_document_diagnostics<CR>'  , 'document_diagnostics'},
        D     = {'<Cmd>Telescope lsp_workspace_diagnostics<CR>' , 'workspace_diagnostics'},
        p     = {'<Cmd>Telescope find_files<CR>'                , 'files'},
        f     = {'<Cmd>Telescope current_buffer_fuzzy_find<CR>' , 'files'},
        h     = {'<Cmd>Telescope command_history<CR>'           , 'history'},
        i     = {'<Cmd>Telescope media_files<CR>'               , 'media files'},
        m     = {'<Cmd>Telescope marks<CR>'                     , 'marks'},
        M     = {'<Cmd>Telescope man_pages<CR>'                 , 'man_pages'},
        o     = {'<Cmd>Telescope vim_options<CR>'               , 'vim_options'},
        T     = {'<Cmd>Telescope live_grep<CR>'                 , 'Project wide search'},
        t     = {'<Cmd>Telescope grep_string<CR>'               , 'Current buffer search'},
        w     = {'<Cmd>Telescope file_browser<CR>'              , 'File Browser'},
        u     = {'<Cmd>Telescope colorscheme<CR>'               , 'Switch colorschemes'},
        s     = {'<Cmd>call SearchString()<CR>'                 , 'Search a string'},
        S     = {'<Cmd>CtrlSFToggle<CR>'                        , 'Search a string toggle'},
        R     = {'<Cmd>help ctrlsf-options<CR>'                 , 'Show CtrlSF options'},
    },
    S = {
        name = '+Session',
        s    = {'<Cmd>Dashboard<CR>' , 'Dashboard'},
    },
    g = {
        name = '+git' ,
        b    = {'<Cmd>GitBlameToggle<CR>' , 'blame'},
        d    = {'<Cmd>DiffviewOpen<CR>'   , 'Diff view'},
        D    = {'<Cmd>DiffviewClose<CR>'  , 'Diff view close'},
    },
    l = {
        name = '+lsp',
        a    = {'<Cmd>Lspsaga code_action<CR>'                 , 'code action'},
        A    = {'<Cmd>Lspsaga range_code_action<CR>'           , 'selected action'},
        d    = {'<Cmd>Telescope lsp_document_diagnostics<CR>'  , 'document diagnostics'},
        D    = {'<Cmd>Telescope lsp_workspace_diagnostics<CR>' , 'workspace diagnostics'},
        f    = {'<Cmd>LspFormatting<CR>'                       , 'format'},
        v    = {'<Cmd>LspVirtualTextToggle<CR>'                , 'lsp toggle virtual text'},
        L    = {'<Cmd>Lspsaga show_line_diagnostics<CR>'       , 'line_diagnostics'},
        p    = {'<Cmd>Lspsaga preview_definition<CR>'          , 'preview definition'},
        q    = {'<Cmd>Telescope quickfix<CR>'                  , 'quickfix'},
        r    = {'<Cmd>Lspsaga rename<CR>'                      , 'rename'},
        T    = {'<Cmd>LspTypeDefinition<CR>'                   , 'type defintion'},
        x    = {'<Cmd>cclose<CR>'                              , 'close quickfix'},
        s    = {'<Cmd>Telescope lsp_document_symbols<CR>'      , 'document symbols'},
        S    = {'<Cmd>Telescope lsp_workspace_symbols<CR>'     , 'workspace symbols'},
        l    = {'<Cmd>LspTroubleToggle<CR>'                    , 'Lsp Trouble toggle'},
    },
    t = {
        name  = '+terminal',
        [';'] = {'<Cmd>FloatermNew --wintype=popup --height=6<CR>' , 'terminal'},
        g     = {'<Cmd>FloatermNew lazygit<CR>'                    , 'lazygit'},
        t     = {'<Cmd>FloatermToggle<CR>'                         , 'toggle'},
        y     = {'<Cmd>FloatermNew ytop<CR>'                       , 'ytop'},
    },
    z = {
        name  = '+TrueZen',
        a = {'<Cmd>TZAtaraxis<CR>'   , 'TrueZen Ataraxis'},
        f = {'<Cmd>TZFocus<CR>'      , 'TrueZen Focus'},
        m = {'<Cmd>TZMinimalist<CR>' , 'Minimal'},
    }
}, { prefix = "<Leader>" })

-- VimScript
vim.cmd([[
    function! SearchString()
        call inputsave()
        let replacement = input('Enter a string: ')
        call inputrestore()
        execute "CtrlSF '" . replacement . "'"
    endfunction
]])
