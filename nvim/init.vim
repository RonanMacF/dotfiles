" read custom plugin configurations
for f in split(glob('~/dotfiles/nvim/plugins/*.vim'), '\n')
        exe 'source' f
endfor

" system settings {{{
	set shell=/bin/zsh                          " Prefer zsh for shell-related tasks
	set hidden                                  " Prefer hiding over unloading buffers
	set mouse=a                                 " Enable mouse usage, e.g. for resizing windows
        set shada=!,'100,f1,h,
	set spelllang=en_gb
        set spellfile=$HOME/dotfiles/nvim/spell/en.utf-8.add
	set backspace=indent,eol,start
	set wildmode=longest:full,full
        set wildoptions=pum
	set splitbelow splitright
        let g:netrw_dirhistmax = 0                  " Prevent .netrwhist file from being created
        set clipboard+=unnamedplus
        set foldmethod=marker
        set autoread

        " encoding
	set encoding=utf-8
        set fileencoding=utf-8
        scriptencoding utf-8

        " Using double trailing slashes in the path tells vim to enable a feature where it avoids name collisions
        set undofile
        set undodir=$HOME/.config/nvim/undo//
        set backup
        set writebackup
        set backupdir=$HOME/.config/nvim/backup//
        set directory=$HOME/.config/nvim/swap//
" }}}

" text formatting settings {{{
	set tabstop=8 softtabstop=4 shiftwidth=4    " Prefer spaces over tabs, width = 4, default behaviour
	set expandtab
        set shiftround
        set formatoptions=tcqn1j " note this is modified by filetype plugin
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
        hi! TermCursorNC ctermfg=15 guifg=#fdf6e3 ctermbg=14 guibg=#93a1a1 cterm=NONE gui=NONE
        set noshowmode
        " Character to show before the lines that have been soft-wrapped
        set showbreak=↪
        " Do not wrap inside words
        set linebreak
        set nojoinspaces " dont use two spaces when joining lines using 'J' and it contains a fullstop
        set termguicolors " https://gist.github.com/XVilka/8346728
        " italicize comments  
        highlight Comment cterm=italic gui=italic            
        set fillchars=vert:│,fold:-
        set whichwrap=b,s,<,>,[,] " make backspace, space and arrow keys work nrmally on wrapped lines
        set diffopt=filler,vertical
" }}}

" search settings {{{
	set incsearch ignorecase smartcase hlsearch " highlight while searching, be smart about the case
        set gdefault   " when on, the :substitute flag 'g' is default on
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
        tnoremap <M-[> <Esc>

        " Black hole deletes
        nnoremap <leader>d "_d
        
        " new line in normal mode and back
        map <Enter> o<ESC>
        map <S-Enter> O<ESC>
        
        " make Y work like D and C
        nnoremap Y yf$

        " qq to record, Q to replay
        nnoremap Q @q
        
        " switch buffer from insert mode in terminal
        tmap [b <Esc><Plug>unimpairedBPrevious
        tmap ]b <Esc><Plug>unimpairedBNext

        " ctrl style quit/save/copy/paste
        inoremap <C-s>     <C-O>:update<cr>

        nnoremap <C-s>     :update<cr>
        inoremap <C-Q>     <esc>:q<cr>
        nnoremap <C-Q>     :q<cr>
        vnoremap <C-Q>     <esc>
        nnoremap <leader>w :w!<CR>
        nnoremap <leader>q :q!<CR>

        " jk escaping
        inoremap jk <Esc>
        xnoremap jk <Esc>
        cnoremap jk <C-c>

        " Keep search results at the center of screen
        " nmap n nzz
        " nmap N Nzz
        " nmap * *zz
        " nmap # #zz
        " nmap g* g*zz
        " nmap g# g#zz
        
        " better visual mode indentation
        xnoremap < <gv
        xnoremap > >gv
        " TODO: automaticaly set paste and use OSC52 escape sequence
" }}}

" autocommands {{{
        " source vimrc when edited
        augroup Vimrc
            autocmd! bufwritepost .vimrc source $MYVIMRC
        augroup ENDV

        " relative numbers on normal mode only
        augroup numbertoggle
                autocmd!
                autocmd InsertLeave * set relativenumber
                autocmd InsertEnter * set norelativenumber
        augroup END
        
        " open help in vertical split
        autocmd FileType help wincmd L
        
        au TermOpen,TermEnter,BufEnter * if &buftype == 'terminal' | :startinsert | endif
" }}}


" read work specific vimrc if exists
if filereadable(expand("~/.vim/custom.vim"))
	execute "source " . "~/.vim/custom.vim"
endif
