"------------------------------------------------------------
" File:    autoload/csedit/dumper.vim
" Author:  nokobear <nokobear.git at gmail dot com>
" URL:     https://github.com/nokobear/vim-colorscheme-edit
" License: MIT license
"------------------------------------------------------------
if exists('*s:__') | finish | endif

" customize
func s:global()
  let g:csedit_en_dump_guisp = get(g:,'csedit_en_dump_guisp', 0 )
  let g:csedit_text_header   = get(g:,'csedit_text_header', s:_header )
  let g:csedit_text_footer   = get(g:,'csedit_text_footer', s:_footer )
  let g:csedit_text_man      = get(g:,'csedit_text_man',    s:_man    )
  let g:csedit_text_note     = get(g:,'csedit_text_note',   s:_note   )
endfunc

" ref
"------------------------------------------------------------
func s:__()
  let s:__info = csedit#info#__()
  let s:__file = csedit#file#__()
  let s:__rgb  = csedit#rgb#__()
  call s:global()
endfunc
func csedit#dumper#__()
  if exists('s:__') | return s:__ | endif
  let s:__ = {}
  let s:__.dump = funcref( 's:_dump' ) " (en_dumpall)
  return s:__
endfunc

" members
let s:_header =
  \ "\" Header\n\"  Please edit this text."
let s:_footer =
  \ "\" Created with vim-colorscheme-edit ". csedit#version() ."\n".
  \ "\"   https://github.com/nokobear/vim-colorscheme-edit"
let s:_man =
  \ "#  CTRL-l  redraw highlights\n".
  \ "#  CTRL-s  write colorscheme to file\n".
  \ "#----------------------------------------"
let s:_note =
  \ "\n# NOTE:\n".
  \ "#----------------------------------------\n".
  \ "# attr:\n".
  \ "#   bold inverse italic nocombine reverse standout\n".
  \ "#   strikethrough undercurl underline\n".
  \ "#\n".
  \ "# sp:\n".
  \ "#   sp defines attr-colors such as undercurl or strikethrough.\n".
  \ "#   It is available only in GUI mode.\n".
  \ "# use as follows\n".
  \ "# name           fg    bg  sp    attr\n".
  \ "# DiffDelete     196   -   124   strikethrough\n".
  \ "# DiffAdd        231   -   231   bold,italic,undercurl\n".
  \ "#----------------------------------------"

" func
"------------------------------------------------------------
func s:_dump( ... )
  let _en_dumpall = get(a:,1,0)
  let _data = s:_dump_data()
  let _data = s:_dump_filter( _data, _en_dumpall )
  let _txt  = s:_dump_render( _data )
  let _len  = s:_id_len(_data) + 2
  let _header = "HeaderBegin:\n" . g:csedit_text_header . "\nHeaderEnd:\n"
  let _footer = "\nFooterBegin:\n" . g:csedit_text_footer . "\nFooterEnd:\n"
  let _backg  = "background: ". (empty(&background)?'dark':&background). "\n\n"
  let _man    = g:csedit_text_man  . "\n"
  let _note   = g:csedit_text_note . "\n"
  let _desc   = printf("# %-"._len."s%-3s  %-3s  %s\n",'name','fg','bg','sp/attr')
  let _txt = _header._backg._man._desc._txt._footer._note
  return _txt
endfunc

func s:_dump_data()
  let buf = execute('hi')
  let data = {}
  let idx=0
  let _normfg = ''
  let _normbg = ''
  for line in split(buf,"\n")
    if line =~ '^S\?csedit' | continue | endif
    if line =~ 'cleared$' | continue | endif
    if line !~ '^\c[a-z_][a-z_0-9]\+ ' | continue | endif
    let lstl = split(line,'links to ')
    let lst = split(lstl[0],' \+')
    let id = lst[0]
    let fg = ''
    let bg = ''
    let sp = ''
    let attr = ''
    let guifg = ''
    let guibg = ''
    let guisp = ''
    let guiattr = ''
    let link = len(lstl)==2 ? split(lstl[1],' \+')[0] : ''
    if empty(link)
      for cel in lst[1:]
        if cel !~ '=' | continue | endif
        let [k,v] = split(cel,"=")
        if k=='ctermfg' | let fg=v   | endif
        if k=='ctermbg' | let bg=v   | endif
        if k=='cterm'   | let attr=v | endif
        if k=='guifg'   | let guifg=v   | endif
        if k=='guibg'   | let guibg=v   | endif
        if k=='guisp'   | let guisp=v   | endif
        if k=='gui'     | let guiattr=v | endif
      endfor
      "if empty(fg) && !empty(guifg)
      "  echo 'fg:'.fg.' guifg:'.guifg . ' conv:'. s:__rgb.rrggbb_to_idx(guifg)
      "endif
      if empty(fg) && !empty(guifg) | let fg=s:__rgb.rrggbb_to_idx(guifg) | endif
      if empty(bg) && !empty(guibg) | let bg=s:__rgb.rrggbb_to_idx(guibg) | endif
      if              !empty(guisp) | let sp=s:__rgb.rrggbb_to_idx(guisp) | endif
      if empty(attr) && !empty(guiattr) | let attr=guiattr | endif
      let fg = empty(fg) ? '-' : fg
      let bg = empty(bg) ? '-' : bg
      let sp = empty(sp) ? '-' : sp
    endif
    if id=~'^\cNormal$'
      let [_normfg,_normbg] = [fg,bg]
    endif
    let data[id] = { 'id':id,'fg':fg,'bg':bg,'sp':sp,'attr':attr,'link':link,'idx':idx }
    let idx = idx+1
  endfor
  " replace fg/bg
  for v in values(data)
    let v.fg = v.fg=='fg' ? _normfg : v.fg=='bg' ? _normbg : v.fg
    let v.bg = v.bg=='fg' ? _normfg : v.bg=='bg' ? _normbg : v.bg
    let v.sp = v.bg=='fg' ? _normfg : v.bg=='bg' ? _normbg : v.sp
  endfor
  return data
endfunc

func s:_dump_filter( data, en_dumpall )
  let _data = {}
  let _ids = {}
  let idx = 0
  for k in csedit#hi_grp#list()
    let lk = tolower(k)
    if !has_key(_ids,lk)
      let _ids[lk] = { 'id':k, 'idx':idx}
      let idx += 1
    endif
  endfor

  " dump
  let idx=0
  for u in sort(values(_ids),{a,b->a.idx-b.idx})
    let id = u.id
    if !empty(get(a:data,id,{}))
      let v = a:data[id]
      let _data[id] = copy(v) | let _data[id].idx=idx
    else
      let _data[id] = { 'id':id,'fg':'-','bg':'-','sp':'-','attr':'','link':'', 'idx':idx}
      echo id.' does not exist.'
    endif
    let idx = idx + 1
  endfor
  if !a:en_dumpall | return _data | endif

  " dump all(additional records)
  for v in sort(values(a:data),{a,b->a.idx-b.idx})
    let id = v.id
    let lk = tolower(id)
    if !has_key(_ids,lk)
      let _data[id] = copy(v) | let _data[id].idx=idx
      let idx = idx + 1
    endif
  endfor
  return _data
endfunc

func s:_dump_render(data)
  let d = a:data
  let id_len = s:_id_len(d)+2
  let _txt = ''
  for id in sort(keys(d),{a,b -> d[a].idx - d[b].idx})
    let [fg,bg,sp,link,attr] = [ d[id].fg, d[id].bg, d[id].sp, d[id].link,d[id].attr ]
    if !empty(link)
      let cmd = printf( '%-'.id_len.'s %s', id,link )
    else
      if id =~ '^\cNormal$'
        let cmd =
          \ s:_print( id_len,'dark.Normal', fg, 235, sp, attr )."\n".
          \ s:_print( id_len,'light.Normal',fg, 252, sp, attr )
      else
        let cmd = s:_print( id_len, id, fg, bg, sp, attr )
      endif
    endif
    let _txt.=cmd."\n"
  endfor
  return _txt
endfunc

func s:_print( id_len, id, fg, bg, sp, attr )
  let en_sp = g:csedit_en_dump_guisp && a:sp!='-'
  return
    \ en_sp ? printf( '%-'.a:id_len."s %3s  %3s  %3s  %s",a:id,a:fg,a:bg,a:sp,a:attr ) :
    \         printf( '%-'.a:id_len."s %3s  %3s  %s",a:id,a:fg,a:bg,a:attr )
endfunc

func s:_id_len( data )
  let _max = 0
  for id in keys(a:data) + ['light.Normal']
    let l = len(id)
    let _max = l>_max ? l : _max
  endfor
  return _max
endfunc

call s:__()
