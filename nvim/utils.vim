
" forward mappings
nnoremap <silent> <F7> :lua require'dap'.step_over()<CR>
nnoremap <silent> <F8> :lua require'dap'.step_into({askForTargets=true})<CR>
nnoremap <silent> <F9> :lua require'dap'.run_to_cursor()<CR>
nnoremap <silent> <F10> :lua require'dap'.continue()<CR>

nnoremap <silent> <F1> :lua require'dap'.step_out()<CR>
nnoremap <silent> <F2> :lua require'dap'.step_back()<CR>
nnoremap <silent> <F3> :lua require'dap'.reverse_continue()<CR>


nnoremap <silent> <leader>ds :lua require'dap'.stop()<CR>
nnoremap <silent> <leader>dd :lua require'dap'.disconnect()<CR>
nnoremap <silent> <leader>dl :lua require('dap').run_last()<CR>

" breakpoint mappings
nnoremap <silent> <leader>bb :lua require'dap'.toggle_breakpoint()<CR>
nnoremap <silent> <leader>bc :lua require'dap'.toggle_breakpoint(vim.fn.input('Breakpoint Condition: '), nil, nil, true)<CR>
nnoremap <silent> <leader>bl :lua require'dap'.toggle_breakpoint(nil, nil, vim.fn.input('Log point message: '), true)<CR>
nnoremap <silent> <leader>lb :lua require'dap'.list_breakpoints()

" testing funcs
nmap <leader>tn <Plug>(ultest-run-nearest)
nmap <leader>tf <Plug>(ultest-run-file)
nmap <silent><leader>ts :TestSuite<CR>
nmap <silent><leader>tl :TestLast<CR>
nmap <silent><leader>tv :TestVisit<CR>
nmap <silent><leader>tm :make test<CR>
nmap <leader>df <Plug>(ultest-debug)
nmap <leader>dn <Plug>(ultest-debug-nearest)

nmap <leader>uos <Plug>(ultest-output-show)
nmap <leader>uoj <Plug>(ultest-output-jump)
nmap <leader>ust <Plug>(ultest-summary-toggle)
nmap <leader>usj <Plug>(ultest-summary-jump)

nmap <leader>]f <Plug>(ultest-next-fail)
nmap <leader>[f <Plug>(ultest-prev-fail)


" toggle views
nnoremap <silent> <M-t> :lua require'dapui'.float_element("stacks")<cr>
nnoremap <silent> <M-s> :lua require'dapui'.float_element("scopes")<cr>
nnoremap <silent> <M-r> :lua require'dapui'.float_element("repl")<cr>
nnoremap <silent> <M-h> :lua require('dapui').toggle()<cr>
nnoremap <silent> <M-p> :lua require'dap'.repl.toggle({height=15})<cr>
