set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/dotfiles/nvim/plugins/vim-startify.vim
source ~/dotfiles/nvim/plugins/vim-signify.vim
source ~/dotfiles/nvim/plugins/coc-nvim.vim
source ~/dotfiles/nvim/plugins/rainbow.vim
source ~/dotfiles/nvim/plugins/vim-go.vim

" system settings {{{
	set shell=/bin/zsh                          " Prefer zsh for shell-related tasks
	set hidden                                  " Prefer hiding over unloading buffers
	set noswapfile                              " No swapfiles period.
	set mouse=a                                 " Enable mouse usage, e.g. for resizing windows
	set noswapfile                              " No swapfiles period.
	set spelllang=en_gb
	set backspace=indent,eol,start
	set encoding=utf-8
        set fileencoding=utf-8
	set wildmode=list:longest,list:full
	set splitbelow splitright
        let g:netrw_dirhistmax = 0                  " Prevent .netrwhist file from being created
        set foldmethod=marker
" }}}

" text formatting settings {{{
	set tabstop=8 softtabstop=4 shiftwidth=4    " Prefer spaces over tabs, width = 4, default behaviour
	set expandtab
        set shiftround
" }}}

" TTY Performance {{{
	set nocompatible
	set synmaxcol=300
	set ttyfast
	set lazyredraw
" }}}

" appearence {{{
	colorscheme gruvbox
	set t_Co=256
	set cursorline
	set title                                   " Set window title
	set scrolloff=5                             " 5 line buffer at top and bottom of page
	set sidescroll=3
	set number relativenumber
" }}}

" search settings {{{
	set incsearch ignorecase smartcase hlsearch " highlight while searching, be smart about the case
	set inccommand=nosplit
	set grepprg=rg\ --vimgrep
	set grepformat=%f:%l:%c:%m
" }}}

" window switching {{{
        " Terminal mode:
        tnoremap <C-h> <c-\><c-n><c-w>h
        tnoremap <C-j> <c-\><c-n><c-w>j
        tnoremap <C-k> <c-\><c-n><c-w>k
        tnoremap <C-l> <c-\><c-n><c-w>l
        " Insert mode:
        inoremap <C-h> <Esc><c-w>h
        inoremap <C-j> <Esc><c-w>j
        inoremap <C-k> <Esc><c-w>k
        inoremap <C-l> <Esc><c-w>l
        " Visual mode:
        vnoremap <C-h> <Esc><c-w>h
        vnoremap <C-j> <Esc><c-w>j
        vnoremap <C-k> <Esc><c-w>k
        vnoremap <C-l> <Esc><c-w>l
        " Normal mode:
        nnoremap <C-h> <c-w>h
        nnoremap <C-j> <c-w>j
        nnoremap <C-k> <c-w>k
        nnoremap <C-l> <c-w>l
" }}}

" mappings {{{
        " terminal mode ESC mapping
        tnoremap <Esc> <C-\><C-n>
        tnoremap <M-[> <Esc

        " Black hole deletes
        nnoremap <leader>d "_d
" }}}

" autocommands {{{
        " source vimrc when edited
        augroup Vimrc
            autocmd! bufwritepost .vimrc source $MYVIMRC
        augroup ENDV
" }}}


" read work specific vimrc if exists
if filereadable(expand("~/.vim/custom.vim"))
	execute "source " . "~/.vim/custom.vim"
endif
