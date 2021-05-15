" ================ Lf =======================
let s:choice_file_path = tempname()

if exists('g:lf_command_override')
  let s:lf_command = g:lf_command_override
else
  let s:lf_command = 'lf'
endif

function! OpenLfIn(path, edit_cmd)
  let oldguioptions = &guioptions
  let s:oldlaststatus = &laststatus
  try
    if has('nvim')
      set laststatus=0
      let currentPath = expand(a:path)
      let lfCallback = { 'name': 'lf', 'edit_cmd': a:edit_cmd }
      function! lfCallback.on_exit(job_id, code, event)
        if a:code == 0
          if exists(":Bclose")
            silent! Bclose!
          else
            echoerr "Failed to close buffer, make sure the `rbgrouleff/bclose.vim` plugin is installed"
          endif
        endif
        try
          if filereadable(s:choice_file_path)
            for f in readfile(s:choice_file_path)
              exec self.edit_cmd . f
            endfor
            call delete(s:choice_file_path)
          endif
        endtry
        let &laststatus=s:oldlaststatus
      endfunction
      enew
      call termopen(s:lf_command . ' -selection-path=' . s:choice_file_path . ' "' . currentPath . '"', lfCallback)
      startinsert
    else
      set guioptions+=! " Make it work with MacVim
      let currentPath = expand(a:path)
      silent exec '!' . s:lf_command . ' -selection-path=' . s:choice_file_path . ' "' . currentPath . '"'
      if filereadable(s:choice_file_path)
        for f in readfile(s:choice_file_path)
          exec a:edit_cmd . f
        endfor
        call delete(s:choice_file_path)
      endif
      redraw!
      " reset the filetype to fix the issue that happens
      " when opening lf on VimEnter (with `vim .`)
      filetype detect
    endif
  endtry
  let &guioptions=oldguioptions
endfun

" For backwards-compatibility (deprecated)
if exists('g:lf_open_new_tab') && g:lf_open_new_tab
  let s:default_edit_cmd='tabedit '
else
  let s:default_edit_cmd='edit '
endif

command! LfCurrentFile call OpenLfIn("%", s:default_edit_cmd)
command! LfCurrentDirectory call OpenLfIn("%:p:h", s:default_edit_cmd)
command! LfWorkingDirectory call OpenLfIn(".", s:default_edit_cmd)
command! Lf LfCurrentFile

" To open the selected file in a new tab
command! LfCurrentFileNewTab call OpenLfIn("%", 'tabedit ')
command! LfCurrentFileExistingOrNewTab call OpenLfIn("%", 'tab drop ')
command! LfCurrentDirectoryNewTab call OpenLfIn("%:p:h", 'tabedit ')
command! LfCurrentDirectoryExistingOrNewTab call OpenLfIn("%:p:h", 'tab drop ')
command! LfWorkingDirectoryNewTab call OpenLfIn(".", 'tabedit ')
command! LfWorkingDirectoryExistingOrNewTab call OpenLfIn(".", 'tab drop ')
command! LfNewTab LfCurrentDirectoryNewTab

" For retro-compatibility
function! OpenLf()
  Lf
endfunction

" Open Lf in the directory passed by argument
function! OpenLfOnVimLoadDir(argv_path)
  let path = expand(a:argv_path)

  " Delete empty buffer created by vim
  Bclose!

  " Open Lf
  call OpenLfIn(path, 'edit')
endfunction

" To open lf when vim load a directory
if exists('g:lf_replace_netrw') && g:lf_replace_netrw
  augroup ReplaceNetrwByLfVim
    autocmd VimEnter * silent! autocmd! FileExplorer
    autocmd BufEnter * if isdirectory(expand("%")) | call OpenLfOnVimLoadDir("%") | endif
  augroup END
endif

if !exists('g:lf_map_keys') || g:lf_map_keys
  map <leader>lf :Lf<CR>
endif

" replace netrw with lf
augroup ReplaceNetrwByLfVim
  autocmd VimEnter * silent! autocmd! FileExplorer
  autocmd BufEnter * if isdirectory(expand("%")) | call OpenLfOnVimLoadDir("%") | endif
augroup END
