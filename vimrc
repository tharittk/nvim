syntax on
set number
highlight LineNr ctermfg=Grey guifg=Grey

filetype plugin indent on
" Standard indentation
set tabstop=8
set softtabstop=8
set shiftwidth=8
set noexpandtab
set textwidth=80
set clipboard=unnamedplus
set hlsearch
nnoremap <Space> <Nop>
let mapleader = " "
" ------------------ Plugin
if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
call plug#begin('~/.vim/plugged')
Plug 'vim-airline/vim-airline'
Plug 'kien/ctrlp.vim'
" LSP and Autocomplete
Plug 'prabirshrestha/vim-lsp'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'
call plug#end()

" Show autocomplete popup automatically
let g:asyncomplete_auto_popup = 1
let g:asyncomplete_auto_completeopt = 1
let g:asyncomplete_min_chars = 1     " popup after 1 character

" Popup appearance — show max 5 entries, always show even with 1 match
set completeopt=menuone,noinsert,noselect
set pumheight=5

" ------------------ Plugin Config
" ---- Airline
let g:airline#extensions#tabline#enabled = 1
let g:airline_disable_statusline=1
nmap <Tab> :bnext<CR>

" -----------Buffer Management---------------
set hidden
nmap <leader>l :bnext<CR>
nmap <leader>h :bprevious<CR>
nmap <leader>q :bp <BAR> bd #<CR>
nmap <leader>bl :ls<CR>

let g:ctrlp_working_path_mode = 'r'
nmap <leader>p :CtrlP<cr>
" ---- Clangd / LSP Config
if executable('clangd')
    au User lsp_setup call lsp#register_server({
        \ 'name': 'clangd',
        \ 'cmd': {server_info->['clangd', '--background-index']},
        \ 'allowlist': ['c', 'cc', 'cpp', 'objc', 'objcpp'],
        \ })
endif
let g:lsp_diagnostics_virtual_text_enabled = 1
let g:lsp_diagnostics_echo_cursor = 1
" Bind LSP mappings only when an LSP server attaches to a buffer
function! s:on_lsp_buffer_enabled() abort
    setlocal omnifunc=lsp#complete
    nmap <buffer> K <plug>(lsp-hover)
    nmap <buffer> gd <plug>(lsp-definition)
    nmap <buffer> <C-]> <plug>(lsp-definition)
    nmap <buffer> gr <plug>(lsp-references)
    nmap <buffer> <leader>rn <plug>(lsp-rename)
    nmap <buffer> <leader>d <plug>(lsp-document-diagnostics)
endfunction
augroup lsp_install
    autocmd!
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END
" Auto-complete suggestion behavior
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <cr>    pumvisible() ? asyncomplete#close_popup() : "\<cr>"
