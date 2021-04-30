" Leader Key Maps

" Timeout
let g:which_key_timeout = 100

let g:which_key_display_names = {'<CR>': '↵', '<TAB>': '⇆', " ": 'SPC'}

" Map leader to which_key
nnoremap <silent> <leader> :silent <c-u> :silent WhichKey '<Space>'<CR>
vnoremap <silent> <leader> :silent <c-u> :silent WhichKeyVisual '<Space>'<CR>

let g:which_key_map =  {}
let g:which_key_sep = '→'

" Not a fan of floating windows for this
let g:which_key_use_floating_win = 0
let g:which_key_max_size = 0

" Hide status line
autocmd! FileType which_key
autocmd  FileType which_key set laststatus=0 noshowmode noruler
  \| autocmd BufLeave <buffer> set laststatus=2 noshowmode ruler

let g:which_key_map['/'] = [ ':CommentToggle'                                                  , 'comment']
let g:which_key_map['.'] = [ ':e $MYVIMRC'                                                     , 'open init']
let g:which_key_map[';'] = [ ':Commands'                                                       , 'commands']
let g:which_key_map['='] = [ '<C-W>='                                                          , 'balance windows']
let g:which_key_map['d'] = [ ':BufferClose'                                                    , 'delete buffer']
let g:which_key_map['?'] = [ ':NvimTreeFindFile'                                               , 'find current file' ]
let g:which_key_map['e'] = [ ':NvimTreeToggle'                                                 , 'Explorer' ]
let g:which_key_map['E'] = [ ':NvimTreeRefresh'                                                , 'Refresh explorer' ]
let g:which_key_map['r'] = [ ':Telescope file_browser'                                         , 'File Browser']
let g:which_key_map['R'] = [ ':Telescope file_browser theme=get_dropdown'                      , 'File Browser']
let g:which_key_map['h'] = [ '<C-W>s'                                                          , 'split below']
let g:which_key_map['v'] = [ '<C-W>v'                                                          , 'split right']
let g:which_key_map['W'] = [ 'w'                                                               , 'write' ]
let g:which_key_map['m'] = [ ':call WindowSwap#EasyWindowSwap()'                               , 'move window']
let g:which_key_map['p'] = [ ':Telescope find_files find_command=rg,--ignore,--hidden,--files' , 'search files']
let g:which_key_map['q'] = [ 'q'                                                               , 'quit']
let g:which_key_map['o'] = [ ':Reload'                                                         , 'Reload Config']
let g:which_key_map['O'] = [ ':Restart'                                                        , 'Restart config']
let g:which_key_map['T'] = [ ':set expandtab | :retab'                                         , 'Convert tab to space']

" Group mappings

" . is for emmet
let g:which_key_map['.'] = {
    \ 'name' : '+emmet' ,
    \ ',' : ['<Plug>(emmet-expand-abbr)'         , 'expand abbr'],
    \ ';' : ['<plug>(emmet-expand-word)'         , 'expand word'],
    \ 'u' : ['<plug>(emmet-update-tag)'          , 'update tag'],
    \ 'd' : ['<plug>(emmet-balance-tag-inward)'  , 'balance tag in'],
    \ 'D' : ['<plug>(emmet-balance-tag-outward)' , 'balance tag out'],
    \ 'n' : ['<plug>(emmet-move-next)'           , 'move next'],
    \ 'N' : ['<plug>(emmet-move-prev)'           , 'move prev'],
    \ 'i' : ['<plug>(emmet-image-size)'          , 'image size'],
    \ '/' : ['<plug>(emmet-toggle-comment)'      , 'toggle comment'],
    \ 'j' : ['<plug>(emmet-split-join-tag)'      , 'split join tag'],
    \ 'k' : ['<plug>(emmet-remove-tag)'          , 'remove tag'],
    \ 'a' : ['<plug>(emmet-anchorize-url)'       , 'anchorize url'],
    \ 'A' : ['<plug>(emmet-anchorize-summary)'   , 'anchorize summary'],
    \ 'm' : ['<plug>(emmet-merge-lines)'         , 'merge lines'],
    \ 'c' : ['<plug>(emmet-code-pretty)'         , 'code pretty'],
    \ }

" a = actions
let g:which_key_map.a = {
    \ 'name' : '+actions' ,
    \ 'c' : [':ColorizerToggle'       , 'colorizer'],
    \ 's' : [':let @/ = ""'           , 'remove search highlight'],
    \ 'w' : [':StripWhitespace'       , 'strip whitespace'],
    \ 'm' : [':MarkdownPreviewToggle' , 'markdown preview'],
    \ }

" b = buffer
let g:which_key_map.b = {
    \ 'name' : '+buffer'  ,
    \ 'd'    : [':BufferClose'              , 'delete-buffer'],
    \ 'D'    : [':BufferCloseAllButCurrent' , 'close all but current'],
    \ 's'    : [':Dashboard'                , 'Dashboard'],
    \ 'p'    : [':BufferPick'               , 'Pick Buffer'],
    \ 'h'    : [':BufferMovePrevious'       , 'Move left'],
    \ 'l'    : [':BufferMoveNext'           , 'Move right'],
    \ 'b'    : [':BufferOrderByDirectory'   , 'Order buffers by directory'],
    \ 'L'    : [':BufferCloseBuffersRight'  , 'Close all buffer on right'],
    \ 'H'    : [':BufferCloseBuffersLeft'   , 'Close all buffer on left'],
    \ }

" D is for debug
let g:which_key_map.D = {
    \ 'name' : '+debug' ,
    \ 'b' : ['DebugToggleBreakpoint ' , 'toggle breakpoint'],
    \ 'c' : ['DebugContinue'          , 'continue'],
    \ 'i' : ['DebugStepInto'          , 'step into'],
    \ 'o' : ['DebugStepOver'          , 'step over'],
    \ 'r' : ['DebugToggleRepl'        , 'toggle repl'],
    \ 's' : ['DebugStart'             , 'start'],
    \ }

" F is for fold
let g:which_key_map.F = {
    \ 'name': '+fold',
    \ 'O' : [':set foldlevel=20' , 'open all'],
    \ 'C' : [':set foldlevel=0'  , 'close all'],
    \ 'c' : [':foldclose'        , 'close'],
    \ 'o' : [':foldopen'         , 'open'],
    \ '1' : [':set foldlevel=1'  , 'level1'],
    \ '2' : [':set foldlevel=2'  , 'level2'],
    \ '3' : [':set foldlevel=3'  , 'level3'],
    \ '4' : [':set foldlevel=4'  , 'level4'],
    \ '5' : [':set foldlevel=5'  , 'level5'],
    \ '6' : [':set foldlevel=6'  , 'level6']
    \ }

" s is for search powered by telescope
let g:which_key_map.s = {
    \ 'name' : '+search' ,
    \ '.' : [':Telescope filetypes'                 , 'filetypes'],
    \ 'b' : [':Telescope buffers'                   , 'Buffers'],
    \ 'd' : [':Telescope lsp_document_diagnostics'  , 'document_diagnostics'],
    \ 'D' : [':Telescope lsp_workspace_diagnostics' , 'workspace_diagnostics'],
    \ 'f' : [':Telescope find_files'                , 'files'],
    \ 'h' : [':Telescope command_history'           , 'history'],
    \ 'i' : [':Telescope media_files'               , 'media files'],
    \ 'm' : [':Telescope marks'                     , 'marks'],
    \ 'M' : [':Telescope man_pages'                 , 'man_pages'],
    \ 'o' : [':Telescope vim_options'               , 'vim_options'],
    \ 't' : [':Telescope live_grep'                 , 'text'],
    \ 'r' : [':Telescope registers'                 , 'registers'],
    \ 'w' : [':Telescope file_browser'              , 'File Browser'],
    \ 'u' : [':Telescope colorscheme'               , 'colorschemes'],
    \ }

" S = Session
let g:which_key_map.S = {
    \ 'name' : '+Session',
    \ 's' : [':Dashboard'   , 'Dashboard'], 
    \ }

" g is for git
let g:which_key_map.g = {
    \ 'name' : '+git' ,
    \ 'b' : [':GitBlameToggle' , 'blame'],
    \ 'B' : [':GBrowse'        , 'browse'],
    \ 'd' : [':Git diff'       , 'diff'],
    \ 'j' : [':NextHunk'       , 'next hunk'],
    \ 'k' : [':PrevHunk'       , 'prev hunk'],
    \ 'l' : [':Git log'        , 'log'],
    \ 'p' : [':PreviewHunk'    , 'preview hunk'],
    \ 'r' : [':ResetHunk'      , 'reset hunk'],
    \ 'R' : [':ResetBuffer'    , 'reset buffer'],
    \ 's' : [':StageHunk'      , 'stage hunk'],
    \ 'S' : [':Gstatus'        , 'status'],
    \ 'u' : [':UndoStageHunk'  , 'undo stage hunk'],
    \ }

" G is for gist
let g:which_key_map.G = {
    \ 'name' : '+gist' ,
    \ 'b' : [':Gist -b'  , 'post gist browser'],
    \ 'd' : [':Gist -d'  , 'delete gist'],
    \ 'e' : [':Gist -e'  , 'edit gist'],
    \ 'l' : [':Gist -l'  , 'list public gists'],
    \ 's' : [':Gist -ls' , 'list starred gists'],
    \ 'm' : [':Gist -m'  , 'post gist all buffers'],
    \ 'p' : [':Gist -P'  , 'post public gist '],
    \ 'P' : [':Gist -p'  , 'post private gist '],
    \ }

" l is for language server protocol
let g:which_key_map.l = {
    \ 'name' : '+lsp',
    \ 'a' : [':Lspsaga code_action'                 , 'code action'],
    \ 'A' : [':Lspsaga range_code_action'           , 'selected action'],
    \ 'd' : [':Telescope lsp_document_diagnostics'  , 'document diagnostics'],
    \ 'D' : [':Telescope lsp_workspace_diagnostics' , 'workspace diagnostics'],
    \ 'f' : [':LspFormatting'                       , 'format'],
    \ 'I' : [':LspInfo'                             , 'lsp info'],
    \ 'v' : [':LspVirtualTextToggle'                , 'lsp toggle virtual text'],
    \ 'L' : [':Lspsaga show_line_diagnostics'       , 'line_diagnostics'],
    \ 'p' : [':Lspsaga preview_definition'          , 'preview definition'],
    \ 'q' : [':Telescope quickfix'                  , 'quickfix'],
    \ 'r' : [':Lspsaga rename'                      , 'rename'],
    \ 'T' : [':LspTypeDefinition'                   , 'type defintion'],
    \ 'x' : [':cclose'                              , 'close quickfix'],
    \ 's' : [':Telescope lsp_document_symbols'      , 'document symbols'],
    \ 'S' : [':Telescope lsp_workspace_symbols'     , 'workspace symbols'],
	\ 'l' : [':LspTroubleToggle'                    , 'Lsp Trouble toggle'],
    \ }

" t = Terminal
let g:which_key_map.t = {
    \ 'name' : '+terminal' ,
    \ ';' : [':FloatermNew --wintype=popup --height=6' , 'terminal'],
    \ 'g' : [':FloatermNew lazygit'                    , 'lazygit'],
    \ 't' : [':FloatermToggle'                         , 'toggle'],
    \ 'y' : [':FloatermNew ytop'                       , 'ytop'],
    \ }

call which_key#register('<Space>', "g:which_key_map")
