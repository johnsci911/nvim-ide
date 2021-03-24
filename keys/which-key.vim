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
let g:which_key_map['/'] = [ ':call Comment()'                    , 'comment' ]
let g:which_key_map['.'] = [ ':e $MYVIMRC'                        , 'open init' ]
let g:which_key_map[';'] = [ ':Commands'                          , 'commands' ]
let g:which_key_map['='] = [ '<C-W>='                             , 'balance windows' ]
let g:which_key_map['e'] = [ ':CocCommand explorer'               , 'explorer' ]
let g:which_key_map['d'] = [ ':Bdelete'                           , 'delete buffer']
let g:which_key_map['h'] = [ '<C-W>s'                             , 'split below']
let g:which_key_map['v'] = [ '<C-W>v'                             , 'split right']
let g:which_key_map['W'] = [ 'w'                                  , 'write' ]
let g:which_key_map['r'] = [ ':RnvimrToggle'                      , 'ranger' ]
let g:which_key_map['m'] = [ ':call WindowSwap#EasyWindowSwap()'  , 'move window' ]
let g:which_key_map['p'] = [ ':Telescope find_files'              , 'search files' ]
let g:which_key_map['q'] = [ 'q'                                  , 'quit' ]

" a = actions
let g:which_key_map.a = {
    \ 'name' : '+actions' ,
    \ 'c' : [':ColorizerToggle'         , 'colorizer'],
    \ 'e' : [':CocCommand explorer'     , 'explorer'],
    \ 's' : [':let @/ = ""'             , 'remove search highlight'],
    \ 'w' : [':StripWhitespace'         , 'strip whitespace'],
    \ 'm' : [':MarkdownPreview'         , 'markdown preview'],
    \ 'h' : [':SemanticHighlightToggle' , 'markdown preview'],
    \ }

" b = buffer
let g:which_key_map.b = {
    \ 'name' : '+buffer'  ,
    \ 'd'    : [':Bdelete'            , 'delete-buffer'],
    \ 'D'    : [':BufOnly'            , 'delete all but current'],
    \ 's'    : ['Startify'            , 'Startify'],
    \ 'p'    : [':BufferPick'         , 'Pick Buffer'],
    \ 'h'    : [':BufferMovePrevious' , 'Move left'],
    \ 'l'    : [':BufferMoveNext'     , 'Move right'],
    \ }

" s = Search
let g:which_key_map.s = {
    \ 'name' : '+search' ,
    \ '/' : [':History/'              , 'history'],
    \ 'a' : [':Ag'                    , 'text Ag'],
    \ 'b' : [':BLines'                , 'current buffer'],
    \ 'B' : [':Buffers'               , 'open buffers'],
    \ 'c' : [':Commits'               , 'commits'],
    \ 'C' : [':BCommits'              , 'buffer commits'],
    \ 'f' : [':Files'                 , 'files'],
    \ 'g' : [':GFiles'                , 'git files'],
    \ 'G' : [':GFiles?'               , 'modified git files'],
    \ 'h' : [':History'               , 'file history'],
    \ 'H' : [':History:'              , 'command history'],
    \ 'l' : [':Lines'                 , 'lines'] ,
    \ 'm' : [':Marks'                 , 'marks'] ,
    \ 'M' : [':Maps'                  , 'normal maps'] ,
    \ 'p' : [':Helptags'              , 'help tags'] ,
    \ 'P' : [':Tags'                  , 'project tags'],
    \ 's' : [':CocList snippets'      , 'snippets'],
    \ 'S' : [':Colors'                , 'color schemes'],
    \ 't' : [':Rg'                    , 'text Rg'],
    \ 'T' : [':BTags'                 , 'buffer tags'],
    \ 'w' : [':Windows'               , 'search windows'],
    \ 'y' : [':Filetypes'             , 'file types'],
    \ 'z' : [':FZF'                   , 'FZF'],
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
    \ 'b' : [':GBranches'                        , 'blame'],
    \ 'B' : [':GBrowse'                          , 'browse'],
    \ 'c' : [':Git commit'                       , 'commit'],
    \ 'C' : [':GCheckout'                        , 'checkout'],
    \ 'd' : [':Git diff'                         , 'diff'],
    \ 'D' : [':Gdiffsplit'                       , 'diff split'],
    \ 'g' : [':GGrep'                            , 'git grep'],
    \ 'G' : [':Gstatus'                          , 'status'],
    \ 'h' : [':GitGutterLineHighlightsToggle'    , 'highlight hunks'],
    \ 'H' : ['<Plug>(GitGutterPreviewHunk)'      , 'preview hunk'],
    \ 'i' : [':Gist -b'                          , 'post gist'],
    \ 'j' : ['<Plug>(GitGutterNextHunk)'         , 'next hunk'],
    \ 'k' : ['<Plug>(GitGutterPrevHunk)'         , 'prev hunk'],
    \ 'l' : [':Git log'                          , 'log'],
    \ 'm' : ['<Plug>(git-messenger)'             , 'message'],
    \ 'p' : [':Git push'                         , 'push'],
    \ 'P' : [':Git pull'                         , 'pull'],
    \ 'r' : [':GRemove'                          , 'remove'],
    \ 's' : ['<Plug>(GitGutterStageHunk)'        , 'stage hunk'],
    \ 'S' : [':!git status'                      , 'status'],
    \ 't' : [':GitGutterSignsToggle'             , 'toggle signs'],
    \ 'u' : ['<Plug>(GitGutterUndoHunk)'         , 'undo hunk'],
    \ 'v' : [':GV'                               , 'view commits'],
    \ 'V' : [':GV!'                              , 'view buffer commits'],
    \ }

" G = Gist
let g:which_key_map.G = {
    \ 'name' : '+gist' ,
    \ 'a' : [':Gist -a'                          , 'post gist anon'],
    \ 'b' : [':Gist -b'                          , 'post gist browser'],
    \ 'd' : [':Gist -d'                          , 'delete gist'],
    \ 'e' : [':Gist -e'                          , 'edit gist'],
    \ 'l' : [':Gist -l'                          , 'list public gists'],
    \ 's' : [':Gist -ls'                         , 'list starred gists'],
    \ 'm' : [':Gist -m'                          , 'post gist all buffers'],
    \ 'p' : [':Gist -P'                          , 'post public gist '],
    \ 'P' : [':Gist -p'                          , 'post private gist '],
    \ }

" l = language server protocol (LSP)
let g:which_key_map.l = {
    \ 'name' : '+lsp' ,
    \ '.' : [':CocConfig'                          , 'config'],
    \ ';' : ['<Plug>(coc-refactor)'                , 'refactor'],
    \ 'a' : ['<Plug>(coc-codeaction)'              , 'line action'],
    \ 'A' : ['<Plug>(coc-codeaction-selected)'     , 'selected action'],
    \ 'b' : [':CocNext'                            , 'next action'],
    \ 'B' : [':CocPrev'                            , 'prev action'],
    \ 'c' : [':CocList commands'                   , 'commands'],
    \ 'd' : ['<Plug>(coc-definition)'              , 'definition'],
    \ 'D' : ['<Plug>(coc-declaration)'             , 'declaration'],
    \ 'e' : [':CocList extensions'                 , 'extensions'],
    \ 'f' : ['<Plug>(coc-format-selected)'         , 'format selected'],
    \ 'F' : ['<Plug>(coc-format)'                  , 'format'],
    \ 'h' : ['<Plug>(coc-float-hide)'              , 'hide'],
    \ 'i' : ['<Plug>(coc-implementation)'          , 'implementation'],
    \ 'I' : [':CocList diagnostics'                , 'diagnostics'],
    \ 'j' : ['<Plug>(coc-float-jump)'              , 'float jump'],
    \ 'l' : ['<Plug>(coc-codelens-action)'         , 'code lens'],
    \ 'n' : ['<Plug>(coc-diagnostic-next)'         , 'next diagnostic'],
    \ 'N' : ['<Plug>(coc-diagnostic-next-error)'   , 'next error'],
    \ 'o' : ['<Plug>(coc-openlink)'                , 'open link'],
    \ 'O' : [':CocList outline'                    , 'outline'],
    \ 'p' : ['<Plug>(coc-diagnostic-prev)'         , 'prev diagnostic'],
    \ 'P' : ['<Plug>(coc-diagnostic-prev-error)'   , 'prev error'],
    \ 'q' : ['<Plug>(coc-fix-current)'             , 'quickfix'],
    \ 'r' : ['<Plug>(coc-rename)'                  , 'rename'],
    \ 'R' : ['<Plug>(coc-references)'              , 'references'],
    \ 's' : [':CocList -I symbols'                 , 'references'],
    \ 'S' : [':CocList snippets'                   , 'snippets'],
    \ 't' : ['<Plug>(coc-type-definition)'         , 'type definition'],
    \ 'u' : [':CocListResume'                      , 'resume list'],
    \ 'U' : [':CocUpdate'                          , 'update CoC'],
    \ 'z' : [':CocDisable'                         , 'disable CoC'],
    \ 'Z' : [':CocEnable'                          , 'enable CoC'],
    \ }

" t = Terminal
let g:which_key_map.t = {
    \ 'name' : '+terminal' ,
    \ ';' : [':FloatermNew --wintype=popup --height=6'        , 'terminal'],
    \ 'f' : [':FloatermNew fzf'                               , 'fzf'],
    \ 't' : [':FloatermToggle'                                , 'toggle'],
    \ 'y' : [':FloatermNew ytop'                              , 'ytop'],
    \ }

" Register which key map
call which_key#register('<Space>', "g:which_key_map")
