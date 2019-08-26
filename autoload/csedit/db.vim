"------------------------------------------------------------
" File:    autoload/csedit/db.vim
" Author:  nokobear <nokobear.git at gmail dot com>
" URL:     https://github.com/nokobear/vim-colorscheme-edit
" License: MIT license
"------------------------------------------------------------
if exists('*s:__') | finish | endif

" ref
"------------------------------------------------------------
func s:__()
  let s:__info       = csedit#info#__()
  let s:__rgb        = csedit#rgb#__()
  " helper
  let s:__db_builder = csedit#db#builder#__()
  let s:__db_hi      = csedit#db#hi#__()
  let s:__db_parser  = csedit#db#parser#__()
endfunc
func csedit#db#__()
  if exists('s:__') | return s:__ | endif
  let s:__ = {}
  let s:__.frombuf = funcref( 's:_frombuf' ) " -
  return s:__
endfunc

" constructor
func s:_new()
  let __ = {}
  let __.hi      = s:__db_hi.new( __ )
  let __.builder = s:__db_builder.new( __ )
  let __.parser  = s:__db_parser.new( __ )
  let __.data = {}
  let __.keys = funcref( 's:_keys', [__] ) " -
  return __
endfunc

func s:_frombuf()
  let __ = s:_new()
  if !s:__rgb.init()   | return {} | endif
  if !s:_setdata( __ ) | return {} | endif
  return __
endfunc

" func
"------------------------------------------------------------
func s:_setdata( __ )
  call a:__.parser.parse()
  call a:__.hi.count()
  return !empty(a:__.data )
endfunc

func s:_keys( __ )
  let d = a:__.data
  return sort( keys(d), {a,b -> d[a].idx - d[b].idx} )
endfunc

call s:__()
