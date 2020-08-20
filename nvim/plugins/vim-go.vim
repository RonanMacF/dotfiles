let g:go_def_mapping_enabled = 0
let g:go_fmt_command = "goimports"
let g:go_imports_autosave = 1
let g:go_test_show_name = 1 " show failed test name before error 
let g:go_auto_sameids = 1           " highlight uses of the identifier under the cursor
let g:go_doc_popup_window = 1       " use popup window instead of preview
let g:go_def_reuse_buffer = 1       " resuse existing buffer for split/vsplut/tab

g:go_textobj_include_function_doc

" Test using :GoTest, should open term in a split and exit with q
" let g:go_term_enabled = 1
" let g:go_term_mode='vsplit' "DEFAULT"
" Causes some types of jobs to run inside a new terminal according to
"
" let g:go_term_enabled = 1
let g:go_term_mode='vsplit'
" go to alternate test
    " augroup go
    "   autocmd!
    "   autocmd Filetype go
    "     \  command! -bang A call go#alternate#Switch(<bang>0, 'edit')
    "     \| command! -bang AV call go#alternate#Switch(<bang>0, 'vsplit')
    "     \| command! -bang AS call go#alternate#Switch(<bang>0, 'split')
    " augroup END


" The dictionary version allows you to define options for multiple binaries:
" likely useful
" >
"   let g:go_fmt_options = {
"     \ 'gofmt': '-s',
"     \ 'goimports': '-local mycompany.com',
"     \ }

" Use this option to enable fmt's experimental mode. This experimental mode is
" superior to the current mode as it fully saves the undo history, so undo/redo
" doesn't break. However, it's slow (creates/deletes a file for every save) and
" it's causing problems on some Vim versions. This has no effect if
" `g:go_fmt_command` is set to `gopls`. By default it's disabled.
" >

"   let g:go_fmt_experimental = 0


" syntax highlighting
let g:go_highlight_space_tab_error = 1 " highlight tab after space error

let g:go_highlight_operators = 1 " :=, ==, -=
  let g:go_highlight_variable_assignments = 1
  let g:go_highlight_variable_declarations = 1
let g:go_highlight_generate_tags = 1
let g:go_highlight_build_constraints = 1
let g:go_highlight_fields = 1
let g:go_highlight_types = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_function_parameters = 1
let g:go_highlight_functions = 1

" TODO: go-vim debugger vs vimspector

  

