let g:semshi#error_sign="v:false"       " let coc handle error linting
let g:semshi#always_update_all_highlights="v:true"  " better highlighting, more resources

" semshit recommended mappings
" nmap <silent> <leader>rr :Semshi rename<CR>

" nmap <silent> <Tab> :Semshi goto name next<CR>
" nmap <silent> <S-Tab> :Semshi goto name prev<CR>

" nmap <silent> <leader>c :Semshi goto class next<CR>
" nmap <silent> <leader>C :Semshi goto class prev<CR>

" nmap <silent> <leader>f :Semshi goto function next<CR>
" nmap <silent> <leader>F :Semshi goto function prev<CR>

" nmap <silent> <leader>gu :Semshi goto unresolved first<CR>
" nmap <silent> <leader>gp :Semshi goto parameterUnused first<CR>

" nmap <silent> <leader>ee :Semshi error<CR>
" nmap <silent> <leader>ge :Semshi goto error<CR>
