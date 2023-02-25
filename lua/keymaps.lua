vim.api.nvim_set_keymap('n', '<Space>', '<NOP>', {noremap = true, silent = true})
vim.g.mapleader = ' '

-- no hl
vim.api.nvim_set_keymap('n', '<Leader>h', ':set hlsearch!<CR>', {noremap = true, silent = true})

-- explorer
vim.api.nvim_set_keymap('n', '<Leader>e', ':NvimTreeToggle<CR>', {noremap = true, silent = true})

-- better window movement
vim.api.nvim_set_keymap('n', '<C-h>', '<C-w>h', {silent = true})
vim.api.nvim_set_keymap('n', '<C-j>', '<C-w>j', {silent = true})
vim.api.nvim_set_keymap('n', '<C-k>', '<C-w>k', {silent = true})
vim.api.nvim_set_keymap('n', '<C-l>', '<C-w>l', {silent = true})

-- Alternatives
vim.cmd([[
  nnoremap <silent> <C-s> :w<CR>
  nnoremap <silent> <C-Q> :wq!<CR>
  nnoremap <silent> <C-c> <Esc>
]])

-- Terminal window navigation
vim.cmd([[
  tnoremap <C-h> <C-\><C-N><C-w>h
  tnoremap <C-j> <C-\><C-N><C-w>j
  tnoremap <C-k> <C-\><C-N><C-w>k
  tnoremap <C-l> <C-\><C-N><C-w>l
  inoremap <C-h> <C-\><C-N><C-w>h
  inoremap <C-j> <C-\><C-N><C-w>j
  inoremap <C-k> <C-\><C-N><C-w>k
  inoremap <C-l> <C-\><C-N><C-w>l
  tnoremap <Esc> <C-\><C-n>
]])

-- resize with arrows
vim.cmd([[
  nnoremap <silent> <M-k> : resize -2<CR>
  nnoremap <silent> <M-j> : resize +2<CR>
  nnoremap <silent> <M-h> : vertical resize -2<CR>
  nnoremap <silent> <M-l> : vertical resize +2<CR>
]])

-- better indenting
vim.api.nvim_set_keymap('v', '<', '<gv', {noremap = true, silent = true})
vim.api.nvim_set_keymap('v', '>', '>gv', {noremap = true, silent = true})

-- I hate escape
vim.api.nvim_set_keymap('i', 'jk', '<ESC>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('i', 'kj', '<ESC>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('i', 'jj', '<ESC>', {noremap = true, silent = true})

-- Tab switch buffer
vim.api.nvim_set_keymap('n', '<TAB>', ':bnext<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<S-TAB>', ':bprevious<CR>', {noremap = true, silent = true})

-- Move selected line / block of text in visual mode
vim.api.nvim_set_keymap('x', 'K', ':move \'<-2<CR>gv-gv', {noremap = true, silent = true})
vim.api.nvim_set_keymap('x', 'J', ':move \'>+1<CR>gv-gv', {noremap = true, silent = true})

-- Better nav for omnicomplete
vim.cmd('inoremap <expr> <c-j> (\"\\<C-n>\")')
vim.cmd('inoremap <expr> <c-k> (\"\\<C-p>\")')

-- LSP keymaps
vim.cmd('nnoremap <silent> gd <cmd>lua vim.lsp.buf.definition()<CR>')
vim.cmd('nnoremap <silent> gD <cmd>lua vim.lsp.buf.declaration()<CR>')
vim.cmd('nnoremap <silent> gr <cmd>lua vim.lsp.buf.references()<CR>')
vim.cmd('nnoremap <silent> gi <cmd>lua vim.lsp.buf.implementation()<CR>')
-- vim.cmd('nnoremap <silent> <C-k> <cmd>lua vim.lsp.buf.signature_help()<CR>')
-- scroll up hover doc
vim.cmd('command! -nargs=0 LspVirtualTextToggle lua require("lsp/virtual_text").toggle()')

local opts = { noremap = true, silent = true }

vim.keymap.set("n", "gd", ":lua vim.lsp.buf.definition()<CR>", opts) --> jumps to the definition of the symbol under the cursor
vim.keymap.set("n", "<space>k", ":lua vim.lsp.buf.hover()<CR>", opts) --> information about the symbol under the cursos in a floating window
vim.keymap.set("n", "gi", ":lua vim.lsp.buf.implementation()<CR>", opts) --> lists all the implementations for the symbol under the cursor in the quickfix window
vim.keymap.set("n", "<space>rn", ":lua vim.lsp.buf.rename()<CR>", opts) --> renaname old_fname to new_fname
vim.keymap.set("n", "<space>ca", ":lua vim.lsp.buf.code_action()<CR>", opts) --> selects a code action available at the current cursor position
vim.keymap.set("n", "gr", ":lua vim.lsp.buf.references()<CR>", opts) --> lists all the references to the symbl under the cursor in the quickfix window
vim.keymap.set("n", "<space>ld", ":lua vim.diagnostic.open_float()<CR>", opts)
vim.keymap.set("n", "[d", ":lua vim.diagnostic.goto_prev()<CR>", opts)
vim.keymap.set("n", "]d", ":lua vim.diagnostic.goto_next()<CR>", opts)
vim.keymap.set("n", "<space>lq", ":lua vim.diagnostic.setloclist()<CR>", opts)
vim.keymap.set("n", "<space>lf", ":lua vim.lsp.buf.formatting()<CR>", opts) --> formats the current buffer

-- Floaterm
vim.cmd([[
  nnoremap <silent> <F4> :FloatermNew<CR>
  tnoremap <silent> <F4> <C-\><C-n>:FloatermNew<CR>
  nnoremap <silent> <F2> :FloatermPrev<CR>
  tnoremap <silent> <F2> <C-\><C-n>:FloatermPrev<CR>
  nnoremap <silent> <F3> :FloatermNext<CR>
  tnoremap <silent> <F3> <C-\><C-n>:FloatermNext<CR>
  nnoremap <silent> <F1> :FloatermToggle<CR>
  tnoremap <silent> <F1> <C-\><C-n>:FloatermToggle<CR>
]])
