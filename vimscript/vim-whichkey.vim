" Map leader key to which_key
nnoremap <silent> <leader> :silent <c-u> :silent WhichKey '<Space>'<CR>
vnoremap <silent> <leader> :silent <c-u> :silent WhichKeyVisual '<Space>'<CR>

" Create map to add keys to
let g:which_key_map =  {}

" Define a separator
let g:which_key_sep = '→'

" Disable Floating window
let g:which_key_use_floating_win = 0

" Change the colors if you want
highlight default link WhichKey          Operator
highlight default link WhichKeySeperator DiffAdded
highlight default link WhichKeyGroup     Identifier
highlight default link WhichKeyDesc      Function

" Hide status line
autocmd! FileType which_key
autocmd  FileType which_key set laststatus=0 noshowmode noruler
    \| autocmd BufLeave <buffer> set laststatus=2 noshowmode ruler

" Single key bindings
let g:which_key_map['/'] = 'comment toggle' 
let g:which_key_map['.'] = [ ':e $MYVIMRC'                                                     , 'open init']
let g:which_key_map[';'] = [ ':Dashboard'                                                      , 'commands']
let g:which_key_map['='] = [ '<C-W>='                                                          , 'balance windows']
let g:which_key_map['e'] = [ ':NvimTreeToggle'                                                 , 'explorer']
let g:which_key_map['?'] = [ ':NvimTreeFindFile'                                               , 'show current file']
let g:which_key_map['d'] = [ ':Bdelete'                                                        , 'delete buffer']
let g:which_key_map['h'] = [ '<C-W>s'                                                          , 'split below']
let g:which_key_map['v'] = [ '<C-W>v'                                                          , 'split right']
let g:which_key_map['W'] = [ 'w'                                                               , 'write' ]
let g:which_key_map['r'] = [ ':RnvimrToggle'                                                   , 'ranger']
let g:which_key_map['m'] = [ ':call WindowSwap#EasyWindowSwap()'                               , 'move window']
let g:which_key_map['p'] = [ ':Telescope find_files find_command=rg,--ignore,--hidden,--files' , 'search files']
let g:which_key_map['q'] = [ 'q'                                                               , 'quit']

" a = actions
let g:which_key_map.a = {
    \ 'name' : '+actions' ,
    \ 'c' : [':ColorizerToggle'         , 'colorizer'],
    \ 's' : [':let @/ = ""'             , 'remove search highlight'],
    \ }

" b = buffer
let g:which_key_map.b = {
    \ 'name' : '+buffer'  ,
    \ 'd'    : [':Bdelete'             , 'delete-buffer'],
    \ 'D'    : [':BufOnly' 		       , 'delete all but current'],
    \ 's'    : ['Startify'             , 'Startify'],
    \ 'p'    : [':BufferLinePick'      , 'Pick Buffer'],
    \ 'h'    : [':BufferLineMovePrev'  , 'Move left'],
    \ 'l'    : [':BufferLineMoveNext'  , 'Move right'],
    \ }

" s = Search
let g:which_key_map.s = {
    \ 'name' : '+search' ,
    \ 't' : [':Telescope live_grep'                                              , 'Find text in Project'],
    \ 's' : [':Telescope grep_string'                                            , 'Find text in Project'],
    \ 'b' : [':Telescope buffers'                                                , 'Find text in Project'],
    \ 'f' : [':Telescope find_files find_command=rg,--ignore,--hidden,--files'   , 'search files'],
    \ }

" S = Session
let g:which_key_map.S = {
    \ 'name' : '+Session' ,
    \ 'c' : [':SClose'          , 'Close Session']  ,
    \ 'd' : [':SDelete'         , 'Delete Session'] ,
    \ 'l' : [':SLoad'           , 'Load Session']     ,
    \ 's' : [':Startify'        , 'Start Page']     ,
    \ 'S' : [':SSave'           , 'Save Session']   ,
    \ }

" g = Git
let g:which_key_map.g = {
    \ 'name' : '+git' ,
    \ 'a' : [':Git add .'                        , 'add all'],
    \ 'A' : [':Git add %'                        , 'add current'],
    \ 'c' : [':Git commit'                       , 'commit'],
    \ 'd' : [':Git diff'                         , 'diff'],
    \ 'D' : [':Gdiffsplit'                       , 'diff split'],
    \ 'G' : [':Gstatus'                          , 'status'],
    \ 'l' : [':Git log'                          , 'log'],
    \ 'p' : [':Git push'                         , 'push'],
    \ 'P' : [':Git pull'                         , 'pull'],
    \ 'r' : [':GRemove'                          , 'remove'],
    \ }

" l is for language server protocol
let g:which_key_map.l = {
      \ 'name' : '+lsp' ,
      \ 'a' : [':Lspsaga code_action'                , 'code action'],
      \ 'A' : [':Lspsaga range_code_action'          , 'selected action'],
      \ 'd' : [':Telescope lsp_document_diagnostics' , 'document diagnostics'],
      \ 'D' : [':Telescope lsp_workspace_diagnostics', 'workspace diagnostics'],
      \ 'f' : [':LspFormatting'                      , 'format'],
      \ 'I' : [':LspInfo'                            , 'lsp info'],
      \ 'v' : [':LspVirtualTextToggle'               , 'lsp toggle virtual text'],
      \ 'l' : [':Lspsaga lsp_finder'                 , 'lsp finder'],
      \ 'L' : [':Lspsaga show_line_diagnostics'      , 'line_diagnostics'],
      \ 'p' : [':Lspsaga preview_definition'         , 'preview definition'],
      \ 'q' : [':Telescope quickfix'                 , 'quickfix'],
      \ 'r' : [':Lspsaga rename'                     , 'rename'],
      \ 'T' : [':LspTypeDefinition'                  , 'type defintion'],
      \ 'x' : [':cclose'                             , 'close quickfix'],
      \ 's' : [':Telescope lsp_document_symbols'     , 'document symbols'],
      \ 'S' : [':Telescope lsp_workspace_symbols'    , 'workspace symbols'],
      \ }

" t = Terminal
let g:which_key_map.t = {
    \ 'name' : '+terminal' ,
    \ ';' : [':FloatermNew --wintype=popup --height=6'        , 'small terminal'],
    \ 'g' : [':FloatermNew lazygit'                           , 'lazygit'],
    \ 't' : [':FloatermToggle'                                , 'toggle'],
    \ 'y' : [':FloatermNew ytop'                              , 'ytop'],
    \ }

" Register which key map
call which_key#register('<Space>', "g:which_key_map")
