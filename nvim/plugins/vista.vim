" Executive used when opening vista sidebar without specifying it.
let g:vista_default_executive = 'nvim_lsp'
" keep alternate buffer when moving into vista buffer
let g:vista_sidebar_keepalt = 1

" appearence
let g:vista#renderer#enable_icon=0
" How to show the detailed formation of current cursor symbol
let g:vista_echo_cursor_strategy = 'both'
let g:vista_fzf_preview = ['right:40%']
let g:vista_sidebar_width = 50
let g:vista_update_on_text_changed = 1

" close the window when we jump to where we want to go
let g:vista_close_on_jump = 1
let g:vista_close_on_fzf_select = 1

let g:vista_disable_statusline = 1

" mappings
nnoremap <leader>vv :Vista!!<CR>
nnoremap <leader>vf :Vista finder nvim_lsp<CR>


" <CR>  - jump to the tag under the cursor.
" p     - preview the tag under the context via the floating window if it's
"         avaliable.
" s     - sort the symbol alphabetically or the location they are declared.
" q     - close the vista window.

" You can add a mapping to `/` in order to open the vista finder for
" searching by adding the following autocommand in your vimrc:
"  >
 autocmd FileType vista,vista_kind nnoremap <buffer> <silent>  :<c-u>call vista#finder#fzf#Run()<CR>
