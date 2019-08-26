"------------------------------------------------------------
" File:    autoload/csedit/info.vim
" Author:  nokobear <nokobear.git at gmail dot com>
" URL:     https://github.com/nokobear/vim-colorscheme-edit
" License: MIT license
"------------------------------------------------------------
if exists('*s:__') | finish | endif

" ref
"------------------------------------------------------------
func s:__()
endfunc
func csedit#info#__()
  if exists('s:__') | return s:__ | endif
  let s:__ = {}
  let s:__.yn         = funcref( 's:_yn'         ) " query,yn
  let s:__.error      = funcref( 's:_error'      ) " msg
  let s:__.input_path = funcref( 's:_input_path' ) " query,path
  return s:__
endfunc

" func
"------------------------------------------------------------
func s:_yn( query )
  let ans = input( a:query.'[Yn]: ','y' ) | redraw | echo
  let flg = ans=~'^\v\c(yes|y)$'
  if !flg | echo 'Canceled.' | endif
  return flg
endfunc

func s:_error( msg )
  echo '[csedit] Error: '.a:msg
  return
endfunc

func s:_input_path( query,path )
  let ans = input( a:query, a:path ) | redraw | echo
  let flg = !empty(ans)
  if !flg | echo 'Canceled.' | endif
  return ans
endfunc

call s:__()
