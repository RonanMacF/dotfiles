" Use <Tab> and <S-Tab> to navigate through popup menu
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" Set completeopt to have a better completion experience
set completeopt=menuone,noinsert,noselect

" Avoid showing message extra message when using completion
set shortmess+=c

let g:completion_matching_strategy_list = [ 'exact', 'fuzzy', 'substring' ]
let g:completion_matching_smart_case = 1
let g:completion_trigger_keyword_length = 2
" auto-complete parenthesis when autocompleting function
let g:completion_enable_auto_paren = 1 
" auto-change source when current source has no completions available
let g:completion_auto_change_source = 1
" let g:completion_word_ignored_ft - [ "log", "txt" ] " dont use ft for buffers source

" Chain completion list
let g:completion_chain_complete_list = {
            \ 'default' : {
            \   'default': [
            \       {'complete_items': ['lsp', 'ts', 'buffers']},
            \       {'mode': '<c-p>'},
            \       {'mode': '<c-n>'}],
            \   'comment': [],
            \   'string' : [{'complete_items': ['path']}]}}

" change completion sources
imap  <c-j> <Plug>(completion_next_source)
imap  <c-k> <Plug>(completion_prev_source)

"   - snippet parsing, either with plugin or vim-vsnip/vim-vsnip-integ
" 
" possible value: 'UltiSnips', 'Neosnippet', 'vim-vsnip', 'snippets.nvim'
" let g:completion_enable_snippet = 'UltiSnips'
