"------------------------------------------------------------
" File:    plugin/csedit.vim
" Author:  nokobear <nokobear.git at gmail dot com>
" URL:     https://github.com/nokobear/vim-colorscheme-edit
" License: MIT license
"------------------------------------------------------------
if exists('s:did_load') | finish | else | let s:did_load=1 | endif

" ftdetect
au BufEnter,BufRead,BufNewFile *.csed setfiletype csed
au BufUnload *.csed call csedit#db#hi#__().clear()

" keymaps
augroup csedit_keymap
  au FileType csed
    \ call csedit#highlight()|
    \ nnoremap <silent><buffer> <C-l> :<c-u>call csedit#highlight()<cr>|
    \ nnoremap <silent><buffer> <C-s> :<c-u>call csedit#build()<cr>|
    "\ nnoremap <silent><buffer> <C-d> :<c-u>call csedit#build(1)<cr>|
augroup END

" commands
command DumpColorScheme    call csedit#dump(0)
command DumpColorSchemeAll call csedit#dump(1)
