let g:neoformat_python_yapf = {
            \ 'exe': 'yapf',
            \  'stdin': 'True',
            \ 'args': ['--style={"based_on_style: pep8, column_limit=85, continuation_indent_width=3, indent_width=3, space_inside_brackets=True"}'],
            \ }
let g:neoformat_enabled_python = ['yapf']
let g:neoformat_verbose = 1 

