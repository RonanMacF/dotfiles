" Executive used when opening vista sidebar without specifying it.
let g:vista_default_executive = 'coc'
" keep alternate buffer when moving into vista buffer
let g:vista_sidebar_keepalt = 1

" appearence
let g:vista#renderer#enable_icon=0
" How to show the detailed formation of current cursor symbol
let g:vista_echo_cursor_strategy = 'both'
let g:vista_fzf_preview = ['right:35%']
let g:vista_sidebar_width = 50

" mappings
nnoremap <leader>vv :Vista!!<CR>
nnoremap <leader>vf :Vista finder coc<CR>
