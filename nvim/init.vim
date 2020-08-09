set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/dotfiles/nvim/plugins/vim-startify.vim
source ~/dotfiles/nvim/plugins/vim-signify.vim
source ~/dotfiles/nvim/plugins/coc-nvim.vim

" appearence {{{
	colorscheme gruvbox
	set t_Co=256
	set cursorline
	set title                                   " Set window title
	set scrolloff=5                             " 5 line buffer at top and bottom of page
	set sidescroll=3
" }}}
