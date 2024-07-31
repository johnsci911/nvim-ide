local wk = require("which-key")

local flash = require("flash")

wk.add({
  -- Other keymaps from global
  { "<leader>rn", desc = "LSP rename" },

  -- Buffers (Barbar)
  { "<TAB>",   mode = { "n" }, "<Cmd>BufferNext<CR>",     desc = "Buffer Next" },
  { "<S-TAB>", mode = { "n" }, "<Cmd>BufferPrevious<CR>", desc = "Buffer Prev" },

-- Save file (Control+S) (Default if not using TMUX)
  -- { '<C-h>',   mode = { "n" }, '<C-w>h',                  desc = 'Move to window left' },
  -- { '<C-j>',   mode = { "n" }, '<C-w>j',                  desc = 'Move to window down' },
  -- { '<C-k>',   mode = { "n" }, '<C-w>k',                  desc = 'Move to window up' },
  -- { '<C-l>',   mode = { "n" }, '<C-w>l',                  desc = 'Move to window right' },

-- TMUX navigation
  { '<C-h>',   mode = { "n" }, '<Cmd>TmuxNavigateLeft<CR>',   desc = 'Move to window left' },
  { '<C-j>',   mode = { "n" }, '<Cmd>TmuxNavigateDown<CR>',   desc = 'Move to window down' },
  { '<C-k>',   mode = { "n" }, '<Cmd>TmuxNavigateUp<CR>',     desc = 'Move to window up' },
  { '<C-l>',   mode = { "n" }, '<Cmd>TmuxNavigateRight<CR>',  desc = 'Move to window right' },

  -- Flash
  { "s",  mode = { "n", "x", "o" }, function() flash.jump() end,              desc = "Flash" },
  { "S",  mode = { "n", "x", "o" }, function() flash.treesitter() end,        desc = "Flash Treesitter" },
  { "sf", mode = { "n", "x", "o" }, function() flash.treesitter_search() end, desc = "Treesitter Search" },

  -- Whichkey local mappings
  { "<leader>/",     "<Cmd>CommentToggle<CR>",                                      desc = "Comment line" },
  { "<leader>.",     '<Cmd>e $MYVIMRC<CR>',                                         desc = 'My VIMRC' },
  { "<leader>=",     '<C-W>=',                                                      desc = 'Balance windows' },
  { "<leader>d",     '<Cmd>BufferClose<CR>',                                        desc = 'Close buffer' },
  { "<leader>?",     '<Cmd>NvimTreeFindFile<CR>',                                   desc = 'Reveal current file' },
  { "<leader>e",     '<Cmd>NvimTreeToggle<CR>',                                     desc = 'Toggle Explorer' },
  { "<leader>E",     '<Cmd>NvimTreeRefresh<CR>',                                    desc = 'Refresh Explorer' },
  { "<leader>R",     '<Cmd>Telescope find_files theme=get_dropdown<CR>',            desc = 'Small File Browser' },
  { "<leader>f",     '<Cmd>FzfLua grep_curbuf<CR>',                                 desc = 'Fuzzy find current buffer' },
  { "<leader>h",     '<C-W>s',                                                      desc = 'Split Vertical' },
  { "<leader>v",     '<C-W>v',                                                      desc = 'Split Horizontal' },
  { "<leader>q",     '<Cmd>q<CR>',                                                  desc = 'quit' },
  { "<leader>T",     '<Cmd>set expandtab<CR> | <Cmd>%retab!<CR>',                   desc = 'Convert tab to space' },
  { "<leader>P",     '<Cmd>Telescope project<CR>',                                  desc = 'Search Project' },
  { "<leader>p",     '<Cmd>FzfLua files<CR>',                                       desc = 'search files' },
  { "<leader>`",     '<Cmd>:e<CR>',                                                 desc = 'Reload' },
  { "<leader>@",     '<Cmd>FzfLua lsp_document_symbols<CR>',                        desc = 'Search for symbols' },
  { "<leader>G",     '<Cmd>Telescope glyph<CR>',                                    desc = 'Search glyphs' },
  { "<leader>u",     '<Cmd>Lazy<CR>',                                               desc = 'Check Packages' },

  { "<leader>,",     group = "Emmet" },
  { "<leader>,;",    ':call emmet#expandAbbr(1,"")<cr>',                            desc = 'expand word' },
  { "<leader>,,",    ':call emmet#expandAbbr(3,"")<cr>',                            desc = 'expand abbr' },
  { "<leader>,/",    ':call emmet#toggleComment()<cr>',                             desc = 'toggle comment' },
  { "<leader>,u",    ':call emmet#updateTag()<cr>',                                 desc = 'update tag' },
  { "<leader>,d",    ':call emmet#balanceTag(1)<cr>',                               desc = 'balance tag in' },
  { "<leader>,D",    ':call emmet#balanceTag(-1)<cr>',                              desc = 'balance tag out' },
  { "<leader>,n",    ':call emmet#moveNextPrev(0)<cr>',                             desc = 'move next' },
  { "<leader>,N",    ':call emmet#moveNextPrev(1)<cr>',                             desc = 'move prev' },
  { "<leader>,i",    ':call emmet#imageSize()<cr>',                                 desc = 'image size' },
  { "<leader>,j",    ':call emmet#splitJoinTag()<cr>',                              desc = 'split join tag' },
  { "<leader>,k",    ':call emmet#removeTag()<cr>',                                 desc = 'remove tag' },
  { "<leader>,a",    ':call emmet#anchorizeURL(0)<cr>',                             desc = 'anchorize url' },
  { "<leader>,A",    ':call emmet#anchorizeURL(1)<cr>',                             desc = 'anchorize summary' },
  { "<leader>,m",    ':call emmet#mergeLines()<cr>',                                desc = 'merge lines' },
  { "<leader>,c",    ':call emmet#codePretty()<cr>',                                desc = 'code pretty' },
  { "<leader>,t",    '<Cmd>TSBufDisable<CR>',                                       desc = 'Treesitter disable current buffer' },
  { "<leader>,T",    '<Cmd>TSBufEnable<CR>',                                        desc = 'Treesitter enable current buffer' },

  { "<leader>a",     group = "Actions" },
  { "<leader>ac",    '<Cmd>ColorizerToggle<CR>',                                    desc = 'Bracket Colorizer' },
  { "<leader>as",    '<Cmd>noh<CR>',                                                desc = 'Remove search highlight' },
  { "<leader>aw",    '<Cmd>StripWhitespace<CR>',                                    desc = 'Strip whitespace' },
  { "<leader>am",    '<Cmd>MarkdownPreviewToggle<CR>',                              desc = 'Markdown preview' },
  { "<leader>at",    '<cmd>AerialToggle!<CR>',                                      desc = 'AerialToggle' },
  { "<leader>ad",    '<Cmd>Telescope notify<CR>',                                   desc = 'Filter Notification' },

  { "<leader>b",     group = "Buffers" },
  { "<leader>bp",    '<Cmd>BufferPick<CR>',                                         desc = 'Buffer Pick' },
  { "<leader>bw",    '<Cmd>BufferWipeout<CR>',                                      desc = 'Wipeout Buffer' },
  { "<leader>bD",    '<Cmd>BufferCloseAllButCurrent<CR>',                           desc = 'Close all but current' },
  { "<leader>bP",    '<Cmd>BufferPin<CR>',                                          desc = 'Pin buffer' },
  { "<leader>bh",    '<Cmd>BufferMovePrevious<CR>',                                 desc = 'Buffer move left' },
  { "<leader>bl",    '<Cmd>BufferMoveNext<CR>',                                     desc = 'Buffer move right' },
  { "<leader>bb",    '<Cmd>BufferOrderByDirectory<CR>',                             desc = 'Buffer order by directory' },
  { "<leader>bL",    '<Cmd>BufferCloseBuffersRight<CR>',                            desc = 'Close buffers on right' },
  { "<leader>bH",    '<Cmd>BufferCloseBuffersLeft<CR>',                             desc = 'Close buffers on left' },

  { "<leader>D",     group = "Debug" },
  { "<leader>Db",    '<Cmd>DebugToggleBreakpoint<CR>',                              desc = 'toggle breakpoint' },
  { "<leader>Dc",    '<Cmd>DebugContinue<CR>',                                      desc = 'continue' },
  { "<leader>Di",    '<Cmd>DebugStepInto<CR>',                                      desc = 'step into' },
  { "<leader>Do",    '<Cmd>DebugStepOver<CR>',                                      desc = 'step over' },
  { "<leader>Dr",    '<Cmd>DebugToggleRepl<CR>',                                    desc = 'toggle repl' },
  { "<leader>Ds",    '<Cmd>DebugStart<CR>',                                         desc = 'start' },

  { "<leader>F",     group = "Fold" },
  { "<leader>O",     '<Cmd>set foldlevel=20<CR>',                                   desc = 'open all' },
  { "<leader>C",     '<Cmd>set foldlevel=0<CR>',                                    desc = 'close all' },
  { "<leader>c",     '<Cmd>foldclose<CR>',                                          desc = 'close' },
  { "<leader>o",     '<Cmd>foldopen<CR>',                                           desc = 'open' },
  { "<leader>1",     '<Cmd>set foldlevel=1<CR>',                                    desc = 'level1' },
  { "<leader>2",     '<Cmd>set foldlevel=2<CR>',                                    desc = 'level2' },
  { "<leader>3",     '<Cmd>set foldlevel=3<CR>',                                    desc = 'level3' },
  { "<leader>4",     '<Cmd>set foldlevel=4<CR>',                                    desc = 'level4' },
  { "<leader>5",     '<Cmd>set foldlevel=5<CR>',                                    desc = 'level5' },
  { "<leader>6",     '<Cmd>set foldlevel=6<CR>',                                    desc = 'level6' },

  { "<leader>s",     group = "Search" },
  { "<leader>sp",    '<cmd>FzfLua files<cr>',                                       desc = 'files' },
  { "<leader>sb",    '<cmd>FzfLua buffers<CR>',                                     desc = 'Buffers' },
  { "<leader>sf",    '<Cmd>FzfLua grep_curbuf<CR>',                                 desc = 'files' },
  { "<leader>sh",    '<Cmd>FzfLua command_history<CR>',                             desc = 'history' },
  { "<leader>si",    '<Cmd>Telescope media_files<CR>',                              desc = 'media files' },
  { "<leader>sM",    '<Cmd>FzfLua man_pages<CR>',                                   desc = 'man_pages' },
  { "<leader>so",    '<Cmd>Telescope vim_options<CR>',                              desc = 'vim_options' },
  { "<leader>sw",    '<Cmd>Telescope find_files<CR>',                               desc = 'File Browser' },
  { "<leader>sB",    '<Cmd>Telescope bookmarks<CR>',                                desc = 'Browser Bookmarks' },
  { "<leader>sP",    '<Cmd>Telescope neoclip<CR>',                                  desc = 'Clipboard' },
  { "<leader>su",    '<Cmd>FzfLua colorschemes<CR>',                                desc = 'Switch colorschemes' },
  { "<leader>sU",    '<Cmd>lua require(\'material.functions\').toggle_style()<CR>', desc = 'Toggle material styile' },
  { "<leader>ss",    '<Cmd>FzfLua live_grep<CR>',                                   desc = 'Search a string' },
  { "<leader>sS",    '<Cmd>FzfLua grep<CR>',                                        desc = 'Search a string toggle' },
  { "<leader>sR",    '<Cmd>help ctrlsf-options<CR>',                                desc = 'Show CtrlSF options' },
  { "<leader>sF",    '<Cmd>FzfLua<CR>',                                             desc = 'Fzf Commands' },
  { "<leader>sc",    '<Cmd>call SearchString()<CR>',                                desc = 'Find and replace' },
  { "<leader>sC",    '<Cmd>CtrlSFToggle<CR>',                                       desc = 'Find and replace' },
  { "<leader>sg",    '<Cmd>Telescope glyph<CR>',                                    desc = 'Find Glyphs' },

  { "<leader>S",     group = "Sessions" },

  { "<leader>g",     group = "Git" },
  { "<leader>gg",    '<Cmd>Neogit<CR>',                                             desc = 'Neogit' },
  { "<leader>gp",    '<Cmd>Neogit pull<CR>',                                        desc = 'Git Pull' },
  { "<leader>gP",    '<Cmd>Neogit Push<CR>',                                        desc = 'Git Push' },
  { "<leader>gb",    '<Cmd>Telescope git_branches<CR>',                             desc = 'Git branches' },
  { "<leader>gc",    '<Cmd>Telescope git_commits<CR>',                              desc = 'Git commits' },
  { "<leader>gB",    '<Cmd>Telescope git_bcommits<CR>',                             desc = 'Git buffer commits' },
  { "<leader>gs",    '<Cmd>Telescope git_status<CR>',                               desc = 'Git status' },
  { "<leader>gS",    '<Cmd>Telescope git_stash<CR>',                                desc = 'Git stash' },
  { "<leader>gC",    '<Cmd>Telescope conflicts<CR>',                                desc = 'Git conflicts' },
  { "<leader>gv",    '<Cmd>GitBlameToggle<CR>',                                     desc = 'Git blame toggle' },
  { "<leader>gd",    '<Cmd>DiffviewOpen<CR>',                                       desc = 'Diff view open' },
  { "<leader>gD",    '<Cmd>DiffviewClose<CR>',                                      desc = 'Diff view close' },
  { "<leader>gh",    '<Cmd>DiffviewFileHistory<CR>',                                desc = 'Diff view file history' },
  { "<leader>gH",    '<Cmd>DiffviewFileHistory %<CR>',                              desc = 'Diff view current file history' },
  { "<leader>gx",    '<Cmd>DiffviewClose<CR>',                                    desc = 'Diff view close' },
  {
    { "<leader>gh",  group = "Git Hunks" },
    { "<leader>ghp", '<Cmd>Gitsigns preview_hunk<CR>',                              desc = 'Git Preview Hunk' },
    { "<leader>ghP", '<Cmd>Gitsigns preview_hunk_inline<CR>',                       desc = 'Git Preview Hunk Inline' },
    { "<leader>ghs", '<Cmd>Gitsigns stage_hunk<CR>',                                desc = 'Git Stage Hunk' },
    { "<leader>ghr", '<Cmd>Gitsigns reset_hunk<CR>',                                desc = 'Git Reset Hunk' },
    { "<leader>ghR", '<Cmd>Gitsigns refresh<CR>',                                   desc = 'Git Signs Refresh' },
    { "<leader>ghu", '<Cmd>Gitsigns undo_stage_hunk<CR>',                           desc = 'Git Undo Stage Hunk' },
    { "<leader>gh[", '<Cmd>Gitsigns prev_hunk<CR>',                                 desc = 'Git Hunk Previous' },
    { "<leader>gh]", '<Cmd>Gitsigns next_hunk<CR>',                                 desc = 'Git Hunk Next' },
  },

  { "<leader>l",     group = "LSP" },
  { "<leader>ld",    '<Cmd>FzfLua lsp_document_diagnostics<CR>',                    desc = 'document diagnostics' },
  { "<leader>lD",    '<Cmd>FzfLua lsp_workspace_diagnostics<CR>',                   desc = 'workspace diagnostics' },
  { "<leader>lq",    '<Cmd>FzfLua quickfix<CR>',                                    desc = 'quickfix' },
  { "<leader>ls",    '<Cmd>FzfLua lsp_document_symbols<CR>',                        desc = 'document symbols' },
  { "<leader>lS",    '<Cmd>FzfLua lsp_workspace_symbols<CR>',                       desc = 'workspace symbols' },
  { "<leader>lt",    '<Cmd>Trouble diagnostics<CR>',                                desc = 'Lsp trouble' },
  { "<leader>lT",    '<Cmd>TSPlaygroundToggle<CR>',                                 desc = 'Treesitter Playground' },
  { "<leader>lF",    '<Cmd>FormatWrite<CR>',                                        desc = 'Format Write' },

  { "<leader>t",     group = "Tab length and terminal" },
  { "<leader>ts",    '<Cmd>FloatermNew --wintype=split --height=0.4<CR>',           desc = 'terminal win=split' },
  { "<leader>tt",    '<Cmd>FloatermToggle<CR>',                                     desc = 'toggle terminal' },
  { "<leader>tB",    '<Cmd>FloatermNew btop<CR>',                                   desc = 'btop' },
  {
    { "<leader>tT",  group = "Switch tab length" },
    { "<leader>tTa", '<Cmd>set ts=2<CR> | <Cmd>set sw=2<CR>',                       desc = 'Width = 2' },
    { "<leader>tTb", '<Cmd>set ts=4<CR> | <Cmd>set sw=4<CR>',                       desc = 'Width = 4' },
  },

  { "<leader>cp",    ":Silicon<CR>",                                                desc = "Code snapshot" },
})

-- Global Search and replace
vim.cmd([[
  function! SearchString()
    call inputsave()
    let searchSctring = input('Enter a string: ')
    let option = input('Search Options: -R = Regex Pattern | -I = Case Insensitive | -S = Case Sensitive | -W = Excact Words ==> ')
    call inputrestore()
    execute "CtrlSF " . option . " " . searchSctring
  endfunction
]])
