" commit last checked: 593388d

let g:startify_files_number        = 8      " The amount of files to show
let g:startify_update_oldfiles 	   = 1	    " update files on the fly rather than when vim exits
let g:startify_relative_path       = 1      " dont use reltive path for files 
let g:startify_change_to_dir       = 0      " dont change to files dir when loading, keep main cwd
let g:startify_session_persistence = 1      " automatically update sessions when leaving vim etc
let g:startify_change_to_vcs_root  = 1      " change to VCS root directory if applicable
let g:startify_fortune_use_unicode = 1      " use utf-8 encoding
let g:startify_session_sort 	   = 0	    " sort sessions by time rather than alphabeticlly

" lists to be displayed
let g:startify_lists = [
			\ { 'type': 'files',     'header': ['   MRU']            },
			\ { 'type': 'dir',       'header': ['   MRU '. getcwd()] },
			\ { 'type': 'sessions',  'header': ['   Sessions']       },
			\ { 'type': 'bookmarks', 'header': ['   Bookmarks']      },
			\ { 'type': 'commands',  'header': ['   Commands']       },
			\ ]

" ignore these filetypes
let g:startify_skiplist = [
			\ 'COMMIT_EDITMSG',
			\ 'bundle/.*/doc',
			\ '/data/repo/neovim/runtime/doc',
			\ ]

" manually set some bookmarks
let g:startify_bookmarks = [
			\ { 'c': '~/.vimrc' },
			\ ]

" commands to be executed before saving a sessions, used for clean up, e.g.
" unmount things 
let g:startify_session_before_save = [
			\ 'echo "Cleaning up before saving.."',
			\ ]

hi StartifyBracket ctermfg=240
hi StartifyFile    ctermfg=147
hi StartifyFooter  ctermfg=240
hi StartifyHeader  ctermfg=114
hi StartifyNumber  ctermfg=215
hi StartifyPath    ctermfg=245
hi StartifySlash   ctermfg=240
hi StartifySpecial ctermfg=240
