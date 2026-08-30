syntax on
set number
highlight LineNr ctermfg=244 guifg=#808080


filetype plugin indent on
" Standard indentation
set tabstop=8
set softtabstop=8
set shiftwidth=8
set noexpandtab
set textwidth=80
set hlsearch

nnoremap <Space> <Nop>
let mapleader = " "

if has("cscope")
    " 1. Set cscopetag to use cscope before ctags
    set cscopetag

    " 2. Temporarily turn off verbosity so Vim doesn't prompt on connection
    set nocscopeverbose

    " 3. Robust path discovery (searches upward from current file directory)
    let s:db = findfile("cscope.out", ".;")
    if !empty(s:db)
        execute "cs add " . fnameescape(s:db)
    elseif $CSCOPE_DB != ""
        execute "cs add " . fnameescape($CSCOPE_DB)
    endif

    " 4. Restore verbosity so actual query errors are visible
    set cscopeverbose
endif

" --- Optimized Cscope Key Mappings ---
" Added <CR> at the beginning to clear the command line and prevent artifact display
nnoremap <C-\>s :cs find s <C-R>=expand("<cword>")<CR><CR>
nnoremap <C-\>g :cs find g <C-R>=expand("<cword>")<CR><CR>
nnoremap <C-\>c :cs find c <C-R>=expand("<cword>")<CR><CR>
nnoremap <C-\>d :cs find d <C-R>=expand("<cword>")<CR><CR>
nnoremap <C-\>t :cs find t <C-R>=expand("<cword>")<CR><CR>
nnoremap <C-\>f :cs find f <C-R>=expand("<cfile>")<CR><CR>
nnoremap <C-\>i :cs find i <C-R>=expand("<cfile>")<CR><CR>

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
