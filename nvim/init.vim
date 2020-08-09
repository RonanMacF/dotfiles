set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/dotfiles/nvim/plugins/vim-startify.vim
source ~/dotfiles/nvim/plugins/vim-signify.vim
source ~/dotfiles/nvim/plugins/coc-nvim.vim
source ~/dotfiles/nvim/plugins/rainbow.vim

" system settings {{{
	set shell=/bin/zsh                          " Prefer zsh for shell-related tasks
	set hidden                                  " Prefer hiding over unloading buffers
	set noswapfile                              " No swapfiles period.
	set mouse=a                                 " Enable mouse usage, e.g. for resizing windows
	set noswapfile                              " No swapfiles period.
	set spelllang=en_gb
	set backspace=indent,eol,start
	set encoding=utf-8
	set wildmode=list:longest,list:full
	set splitbelow splitright
" }}}

" text formatting settings {{{
	set tabstop=8 softtabstop=4 shiftwidth=4    " Prefer spaces over tabs, width = 4, default behaviour
	set expandtab
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

" read work specific vimrc if exists
if filereadable(expand("~/.vim/custom.vim"))
	execute "source " . "~/.vim/custom.vim"
endif
