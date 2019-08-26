"------------------------------------------------------------
" File:    autoload/csedit/rgb.vim
" Author:  nokobear <nokobear.git at gmail dot com>
" URL:     https://github.com/nokobear/vim-colorscheme-edit
" License: MIT license
"------------------------------------------------------------
if exists('*s:__') | finish | endif

" customize
let g:csedit_str_preset = get(g:,'csedit_str_preset','tango')

" global
let s:_rgb    = []
let s:_rrggbb = []

" ref
"------------------------------------------------------------
func s:__()
  call s:_init()
endfunc
func csedit#rgb#__()
  if exists('s:__') | return s:__ | endif
  let s:__ = {}
  let s:__.init          = funcref( 's:_init'          ) " (_preset)
  let s:__.idx_to_rrggbb = funcref( 's:_idx_to_rrggbb' ) " idx
  let s:__.rrggbb_to_idx = funcref( 's:_rrggbb_to_idx' ) " rrggbb
  let s:__.rgb_to_rrggbb = funcref( 's:_rgb_to_rrggbb' ) " rgb
  let s:__.rrggbb_to_rgb = funcref( 's:_rrggbb_to_rgb' ) " rrggbb
  return s:__
endfunc

" func
"------------------------------------------------------------
func s:_init( ... )
  let _preset = get(a:,1, g:csedit_str_preset )
  let s:_rrggbb = []
  let s:_rgb    = []
  try
    let s:_rrggbb = function( 'csedit#presets#'._preset.'#list' )()
    for idx in range(0,255)
      let _rgb = s:_rrggbb_to_rgb(s:_rrggbb[idx])
      if _rgb[0]==-1 || _rgb[1]==-1 || _rgb[2]==-1 | throw 'e' | endif
      call add(s:_rgb, _rgb )
    endfor
  catch
    let s:_rrggbb = []
    let s:_rgb    = []
  endtry
  if len(s:_rrggbb) !=256 || len(s:_rgb) !=256
    return s:__info.error( 'Failed to load preset "'._preset.'"' )
  endif
  return 1
endfunc

func s:_idx_to_rrggbb( idx )
  return
    \ a:idx!~'^[0-9]\+$' ? a:idx :
    \                      s:_rrggbb[and(a:idx,0xff)]
endfunc

func s:_rrggbb_to_idx( rrggbb )
  " string
  if a:rrggbb !~ '^#\c[0-9a-f]\+$' || len(a:rrggbb)!=7 | return a:rrggbb | endif
  " #rrggbb
  let _idx = -1
  let _min = 3*0xffff
  let _rgb0 = s:_rrggbb_to_rgb(a:rrggbb)
  for i in range(16,255)
    let _rgb = s:_rrggbb_to_rgb(s:_idx_to_rrggbb(i))
    let dr = _rgb[0]-_rgb0[0]
    let dg = _rgb[1]-_rgb0[1]
    let db = _rgb[2]-_rgb0[2]
    let d = dr*dr + dg*dg + db*db
    if d<=_min
      let _idx = i
      let _min = d
    endif
  endfor
  return _idx
endfunc

func s:_rgb_to_rrggbb( rgb )
  return
    \ a:rgb[0]==-1 ? '#ffffff' :
    \                printf('#%02x%02x%02x', [a:rgb[0],a:rgb[1],a:rgb[2]] )
endfunc

func s:_rrggbb_to_rgb( rrggbb )
  " string
  if a:rrggbb !~ '^#\c[0-9a-f]' | return [-1,-1,-1] | endif
  " #rrggbb
  let str = substitute(a:rrggbb,'^#','','')
  let r = eval( '0x'.strpart(str,0,2) )
  let g = eval( '0x'.strpart(str,2,2) )
  let b = eval( '0x'.strpart(str,4,2) )
  return [r,g,b]
endfunc

call s:__()
