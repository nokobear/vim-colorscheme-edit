"------------------------------------------------------------
" File:    autoload/csedit/db/hi.vim
" Author:  nokobear <nokobear.git at gmail dot com>
" URL:     https://github.com/nokobear/vim-colorscheme-edit
" License: MIT license
"------------------------------------------------------------
if exists('*s:__') | finish | endif

" customize
let g:csedit_en_terminal_bg = get( g:,'csedit_en_terminal_bg', 0 )

" global
let s:cse     = 'csedit'  " used as temporarily highlight name.
let s:en_gui  = has('gui_running')
let s:synfile = expand('<sfile>:p:h:h:h').'/syntax/csed.vim'

" ref
"------------------------------------------------------------
func s:__()
  let s:__file = csedit#file#__()
  let s:__rgb  = csedit#rgb#__()
endfunc
func csedit#db#hi#__()
  if exists('s:__') | return s:__ | endif
  let s:__ = {}
  let s:__.new  = funcref( 's:_new' )
  let s:__.clear= funcref( 's:_clear' ) " -
  return s:__
endfunc

" constructor
func s:_new( __db )
  let __ = {}
  let __.idlen   = 0
  let __.en_sp   = 0
  let __.en_attr = 0
  let __.en_link = 0
  let __.count  = funcref( 's:_count',  [a:__db] ) " -
  let __.adjust = funcref( 's:_adjust', [a:__db] ) " -
  let __.draw   = funcref( 's:_draw',   [a:__db] ) " -
  let __.cmd    = funcref( 's:_cmd',    [a:__db] ) " id, method
  return __
endfunc

" func
"------------------------------------------------------------
func s:_count( __ )
  let [idlen,en_sp,en_attr,en_term,en_gui,en_link] = [0,0,0,0,0,0]
  for v in values(a:__.data)
    let l = len(v.id)
    let idlen   = l>idlen ? l : idlen
    let en_sp   += v.sp   !='NONE'
    let en_term += v.term !='NONE'
    let en_gui  += v.gui  !='NONE'
    let en_link += !empty(v.link)
  endfor
  let p = a:__.hi
  let [p.idlen,p.en_sp,p.en_term,p.en_gui,p.en_link]
    \ = [idlen,en_sp,en_term,en_gui,en_link]
endfunc

func s:_adjust( __db )
  for id in a:__db.keys()
    call s:_adjust_id( a:__db, id )
  endfor
endfunc

func s:_adjust_id( __db, id )
  let _p  = a:__db.data[a:id]
  let fg = _p.fg
  let bg = _p.bg
  if a:id =~ 'dark\.'  && bg=='NONE' | let bg = 235 | endif
  if a:id =~ 'light\.' && bg=='NONE' | let bg = 252 | endif
  let fg = fg =~ '^[0-9]\+$' && fg==bg ? and(fg+3,0xff) : fg
  let _p.fg = fg
  let _p.bg = bg
endfunc

func s:_draw( __db )
  call s:_reset()
  for id in a:__db.keys()
    call s:_draw_id( a:__db, id )
  endfor
endfunc

func s:_reset()
  call s:_clear()
  let synfile = s:__file.get_synname()
  if s:__file.exists(synfile)
    exec 'so' synfile
  endif
endfunc

func s:_clear()
  for _line in split(execute('hi'),"\n")
    if _line !~ '^S\?csedit' | continue | endif
    let lst = split(_line,' \+')
    if empty(lst) | continue | endif
    let _tid = lst[0]
    if hlexists(_tid)
      exe 'syn clear '._tid
      exe 'hi clear '._tid
    endif
  endfor
endfunc

func s:_draw_id( __db, id )
  let d = a:__db.data[a:id]
  let p = a:__db.hi
  let [_tid, _tlink] = s:_get_test( a:id, d.link )
  exe 'syn match '._tid.' =^'.a:id.' = contains=ScseditDark,ScseditLight'
  if !empty(d.link)
    exe ''
      \ .s:fmt_link( _tid, _tlink, 0 )
  elseif s:en_gui
    exe ''
      \ .s:fmt_id( _tid, 0, 0 )
      \ .s:fmt_gui_color( _tid, d.fg, d.bg, d.sp, 1 )
      \ .s:fmt_gui_attr( d.gui, 1 )
  else
    exe ''
      \ .s:fmt_id( _tid, 0, 0 )
      \ .s:fmt_term_color( _tid, d.fg, d.bg )
      \ .s:fmt_term_attr( d.term, 1 )
  endif
endfunc

func s:_get_test( id, link )
  let _tid = substitute(s:cse.a:id,'\.','dot','g')
  let _tlink = s:cse.a:link
  return [_tid,_tlink]
endfunc

func s:_cmd( __db, id, method )
  let _dat = a:__db.data[a:id]
  let _link = _dat.link
  let _id = substitute(a:id,'\(dark\.\|light\.\)','','')
  return
    \ !empty(_link)    ? s:_link(  _id, _dat, a:__db.hi ) :
    \ a:method=='term' ? s:_term(  _id, _dat, a:__db.hi ) :
    \ a:method=='gui'  ? s:_gui(   _id, _dat, a:__db.hi ) :
    \                    s:_merge( _id, _dat, a:__db.hi )
endfunc

func s:_link( id, dat, hi )
  let d = a:dat
  let p = a:hi
  return ''
    \ .s:fmt_link( a:id, d.link, p.idlen )
endfunc

func s:_term( id, dat, hi )
  let d = a:dat
  let p = a:hi
  return ''
    \ .s:fmt_id( a:id, p.idlen, p.en_link )
    \ .s:fmt_term_color( a:id, d.fg, d.bg )
    \ .s:fmt_term_attr( d.term, p.en_term )
endfunc

func s:_gui( id, dat, hi )
  let d = a:dat
  let p = a:hi
  return ''
    \ .s:fmt_id( a:id, p.idlen, p.en_link )
    \ .s:fmt_gui_color( a:id, d.fg, d.bg, d.sp, p.en_sp )
    \ .s:fmt_gui_attr( d.gui, p.en_gui )
endfunc

func s:_merge( id, dat, hi )
  let d = a:dat
  let p = a:hi
  return ''
    \ .s:fmt_id( a:id, p.idlen, p.en_link )
    \ .s:fmt_gui_color( a:id, d.fg, d.bg, d.sp, p.en_sp )
    \ .s:fmt_term_color( a:id, d.fg, d.bg )
    \ .s:fmt_gui_attr( d.gui, p.en_gui )
    \ .s:fmt_term_attr( d.term, p.en_term )
endfunc

func s:fmt_link( id, link, idlen )
  return printf( 'hi link %-'.a:idlen.'s %s', a:id, a:link )
endfunc

func s:fmt_id( id, idlen, en_link )
  let sp_link = a:en_link ? '     ' : ''
  return printf('hi %s%-'.a:idlen.'s ', sp_link , a:id)
endfunc

func s:fmt_term_color( id, fg, bg )
  let tfg = a:fg
  let tbg = !g:csedit_en_terminal_bg && a:id =~ '^\cnormal$' ? 'NONE' : a:bg
  return printf( 'ctermfg=%-4s ctermbg=%-4s ', tfg, tbg )
endfunc

func s:fmt_gui_color( id, fg, bg, sp, en_sp )
  let gfg = s:__rgb.idx_to_rrggbb(a:fg)
  let gbg = s:__rgb.idx_to_rrggbb(a:bg)
  let gsp = s:__rgb.idx_to_rrggbb(a:sp)
  return ''
    \ .printf( 'guifg=%-7s guibg=%-7s ', gfg, gbg )
    \ .(a:en_sp ? printf('guisp=%-7s ',gsp ) : '')
endfunc

" NOTE:
" The values 'cterm' and 'gui' are not completely cleared with the command
" ':hi clear' and default values are set. Then I think it is safer not to omit
" them.
func s:fmt_term_attr( term, en_term )
  "return a:en_term ? printf( 'cterm=%s ', a:term ) : ''
  return printf( 'cterm=%s ', a:term )
endfunc

func s:fmt_gui_attr( gui, en_gui )
  "return a:en_gui ? printf( 'gui=%s ', a:gui ) : ''
  return printf( 'gui=%s ', a:gui )
endfunc

call s:__()
