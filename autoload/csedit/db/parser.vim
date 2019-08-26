"------------------------------------------------------------
" File:    autoload/csedit/db/parser.vim
" Author:  nokobear <nokobear.git at gmail dot com>
" URL:     https://github.com/nokobear/vim-colorscheme-edit
" License: MIT license
"------------------------------------------------------------
if exists('*s:__') | finish | endif

" customize
let g:csedit_en_colorname = get(g:,'csedit_en_colorname',1)

" ref
"------------------------------------------------------------
func s:__()
endfunc
func csedit#db#parser#__()
  if exists('s:__') | return s:__ | endif
  let s:__ = {}
  let s:__.new = funcref( 's:_new' ) " -
  return s:__
endfunc

" constructor
func s:_new( __db )
  let __ = {}
  let __.parse = funcref( 's:_parse', [a:__db] ) " -
  return __
endfunc

" func
"------------------------------------------------------------
func s:_parse( __db )
  let _data   = {}
  let _header = ''
  let _footer = ''
  let _background = ''
  let _error = ''
  let en_header = 0
  let en_footer = 0
  let _idx = 0
  let _lnum = 0

  for line in getline(1,'$') " should classify into line?
    let _lnum = _lnum + 1
    let [ _fg, _bg, _sp, _attr, _term, _gui, _link]
      \ = ['NONE', 'NONE', 'NONE', 'NONE', 'NONE', 'NONE', '' ]
    let _line =  s:_trim(line)
    let lst = split( _line, ' ' )

    " here document header/footer
    if len(lst)==1
      let str = lst[0]
      if 0
      elseif str =~ '^\cHeaderBegin:$' | let en_header=1 | continue
      elseif str =~ '^\cHeaderEnd:$'   | let en_header=0 | continue
      elseif str =~ '^\cFooterBegin:$' | let en_footer=1 | continue
      elseif str =~ '^\cFooterEnd:$'   | let en_footer=0 | continue
      endif
    endif
    if en_header | let _header.=line."\n" | continue | endif
    if en_footer | let _footer.=line."\n" | continue | endif

    " get params
    "------------------------------
    " input case:
    "   background: dark
    "   background: light
    "------------------------------
    if _line =~ ':'
      let _vals = split(_line,':')
      let [lval,rval] = [ get(_vals,0,''), get(_vals,1,'')]
      let [lval,rval] = [ trim(tolower(lval),' '), trim(tolower(rval),' ') ]
      " background
      if lval =~ '^\v(background|bg)$'
        if rval =~ '^\v(dark|light|)$'
          let _background = rval
        else
          let _error .= s:_error(_lnum, 'background: must be dark or light or (empty)')
        endif
      endif
      continue
    endif
    
    " parse line
    "------------------------------
    "input case:
    "  0  1    2    3   4
    "  id attr
    "  id 11
    "  id 11   attr
    "  id 11   22
    "  id 11   22   attr
    "  id 11   22   33
    "  id 11   22   33  attr
    "  id linkname
    "  id bold NONE    " this 'bold' is not attr but linkname
    "------------------------------
    if empty(_line) | continue | endif
    if len(lst) < 2
      let _error .= s:_error(_lnum, 'syntax error')
      continue
    endif

    " get id
    if s:is_id(lst[0])
      let _id = lst[0] | let lst=lst[1:] " _id = shift(lst)
    else
      let _error .= s:_error(_lnum, 'invalid id')
      continue
    endif

    " get attr
    if s:is_attr(lst[-1])
      let _attr = lst[-1] | let lst = lst[0:len(lst)-2] " _attr = pop(lst)
      let _term = s:trim_attr(_attr, 0)
      let _gui  = s:trim_attr(_attr, 1)
    endif

    " get colors or linkto
    let _cnt = len(lst)
    if _cnt==0
      let _error .= s:_error(_lnum, 'too few arguments')
      continue
    " get colors (case lists are all colors)
    elseif _cnt<4 && empty(filter(copy(lst),{-> !s:is_color(v:val)}))
      let _fg = s:trim_color( lst[0] )
      "echo 'id:'._id.' fg:'.lst[0].'->'._fg
      let _bg = s:trim_color( get(lst,1,'-') )
      let _sp = s:trim_color( get(lst,2,'-') )
    " or get linkto
    elseif _cnt==1 && s:is_link(lst[0])
      let _link = lst[0]
    else
      if _cnt>=4 | let _error .= s:_error( _lnum, 'too many arguments' )
      else       | let _error .= s:_error( _lnum, 'syntax error' )
      endif
      continue
    endif

    let _data[_id] =
      \ { 'id':_id, 'fg':_fg, 'bg':_bg, 'sp':_sp,
      \  'term':_term, 'gui':_gui, 'link':_link, 'idx':_idx }
    let _idx += 1
  endfor

  let a:__db.data = _data
  let a:__db.builder.header     = _header
  let a:__db.builder.footer     = _footer
  let a:__db.builder.background = _background
  let a:__db.builder.error      = _error
endfunc

func s:_trim(line)
  let _ = a:line
  let _ = substitute( _, '#.*','','' )   " remove comment
  let _ = substitute( _, "\t",' ','g' )  " replace tab to space
  let _ = substitute( _, ' *$','','' )   " trim right space
  let _ = substitute( _, '^ *','','' )   " trim left space (is neccesary?)
  let _ = substitute( _, ' \+',' ','g' ) " shorten spaces
  return _
endfunc

func s:is_id(str)
  return a:str =~ '^\v\c(dark\.|light\.|)[a-z_][a-z_0-9]*$'
endfunc

func s:is_link(str)
  return a:str =~ '^\c[a-z_][a-z_0-9]*$'
endfunc

func s:is_color(str)
  return a:str =~ '^\(-\|[0-9]\+\)$' || s:is_colorname(a:str)
endfunc

" REMIND:
" It may have a problem to overlap with linknames.
func s:is_colorname(str)
  if !g:csedit_en_colorname | return | endif
  let _colornames = [
    \ 'Black', 'DarkBlue', 'DarkGreen', 'DarkCyan', 'DarkRed', 'DarkMagenta',
    \ 'Brown', 'DarkYellow', 'LightGray', 'LightGrey', 'Gray', 'Grey',
    \ 'DarkGray', 'DarkGrey', 'Blue', 'LightBlue', 'Green', 'LightGreen',
    \ 'Cyan', 'LightCyan', 'Red', 'LightRed', 'Magenta', 'LightMagenta',
    \ 'Yellow', 'LightYellow', 'White',
    \ ]
  return a:str =~ '^\v\c('. join(_colornames,'|'). ')$'
endfunc

func s:is_attr(str)
  let _attrs = [
    \ 'bold', 'inverse', 'italic', 'nocombine', 'reverse', 'standout',
    \ 'strikethrough', 'undercurl', 'underline', 'NONE',
    \ ]
  for v in split( a:str, ',' )
    if v !~ '^\v\c('. join(_attrs,'|'). ')$'
      return
    endif
  endfor
  return 1
endfunc

func s:trim_color( col )
  return
    \ a:col =~ '^[0-9]\+$' ? and(a:col,255) :
    \ a:col =~ '^\c[a-z]\+$' ? a:col :
    \                        'NONE'
endfunc

func s:trim_attr( attr, is_gui )
  let d = {} | let idx=0
  for v in split(tolower(a:attr),',')
    if v=='none' || (!a:is_gui && v=~'^\v(undercurl)$') | continue | endif
    if !has_key(d,v)
      let d[v] = idx | let idx += 1
    endif
  endfor
  return empty(d) ? 'NONE' : join(sort(keys(d),{a,b->d[a]-d[b]}),',')
  "ex) sort by ascii
  "return empty(d) ? 'NONE' : join(sort(keys(d)),',')
endfunc

func s:_error( lnum, msg )
  return printf( "line %d: %s\n", a:lnum, a:msg)
endfunc

call s:__()
