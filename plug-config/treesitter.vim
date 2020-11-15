syntax on

if (has("termguicolors"))
    set termguicolors
    hi LineNr ctermbg=NONE guibg=NONE
endif

set background=dark

let g:lightline = { 'colorscheme': 'palenight' }
let g:airline_theme = "palenight"
let g:palenight_terminal_italics=1

colorscheme palenight
