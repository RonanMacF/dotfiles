" Executive used when opening vista sidebar without specifying it.
let g:vista_default_executive = 'coc'
" keep alternate buffer when moving into vista buffer
let g:vista_sidebar_keepalt = 1
" How to show the detailed formation of current cursor symbol
" g:vista_echo_cursor_strategy = 'both'

let g:vista_fzf_preview = ['right:50%']

nnoremap <leader>vv :Vista!!<CR>
nnoremap <leader>vf :Vista finder coc
" You can add a mapping to `/` in order to open the vista finder for
" searching by adding the following autocommand in your vimrc:
"  >
"  autocmd FileType vista,vista_kind nnoremap <buffer> <silent> \
"              / :<c-u>call vista#finder#fzf#Run()<CR>

