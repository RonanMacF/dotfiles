" Executive used when opening vista sidebar without specifying it.
let g:vista_default_executive = 'nvim_lsp'
" keep alternate buffer when moving into vista buffer
let g:vista_sidebar_keepalt = 1

" appearence
let g:vista#renderer#enable_icon=0
" How to show the detailed formation of current cursor symbol
let g:vista_echo_cursor_strategy = 'both'
let g:vista_fzf_preview = ['right:35%']
let g:vista_sidebar_width = 50
let g:vista_update_on_text_changed = 1

" close the window when we jump to where we want to go
let g:vista_close_on_jump = 1
let g:vista_close_on_fzf_select = 1

let g:vista_disable_statusline = 1
