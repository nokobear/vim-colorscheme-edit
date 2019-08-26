"------------------------------------------------------------
" File:    autoload/csedit/file.vim
" Author:  nokobear <nokobear.git at gmail dot com>
" URL:     https://github.com/nokobear/vim-colorscheme-edit
" License: MIT license
"------------------------------------------------------------
if exists('*s:__') | finish | endif

" global
let s:sdir = expand('<sfile>:p:h')
func s:global()
  let s:slash = s:guess_slash()
  " customize
  let g:csedit_str_colors_dir  = get( g:,'csedit_str_colors_dir',  s:guess_colordir() )
  let g:csedit_str_dump_dir    = get( g:,'csedit_str_dump_dir',    s:guess_colordir() )
  let g:csedit_str_dump_prefix = get( g:,'csedit_str_dump_prefix', 'dump-' )
endfunc

" ref
"------------------------------------------------------------
func s:__()
  let s:__info = csedit#info#__()
  call s:global()
endfunc
func csedit#file#__()
  if exists('s:__') | return s:__ | endif
  let s:__ = {}
  let s:__.write         = funcref( 's:_write'        ) " -
  let s:__.get_synname   = funcref( 's:get_synname'   ) " -
  let s:__.get_themename = funcref( 's:get_themename' ) " -
  let s:__.get_vimname   = funcref( 's:get_vimname'   ) " -
  let s:__.get_csename   = funcref( 's:get_csename'   ) " -
  let s:__.exists        = funcref( 's:_exists'       ) " -
  return s:__
endfunc

" func
"------------------------------------------------------------
func s:_write(text, path )
  let path = a:path
  let lst = map(split(a:text,"\n"),{i,v->substitute(v,' *$','','')})
  try
    call writefile(lst,path)
  catch
    return s:__info.error('Failed to write file "'.path.'"')
  endtry
  echo 'Saved to "'.path.'"'
  return 1
endfunc

func s:get_synname()
  return fnamemodify(s:sdir,':h:h').s:slash.'syntax'.s:slash.'csed.vim'
endfunc

func s:get_themename()
  let bname = expand('%:t:r')
  return !empty(bname) ? bname : 'no_name'
endfunc

func s:get_vimname()
  let dir = s:check_dir('g:csedit_str_colors_dir')
  if empty(dir) | return '' | endif
  let bname = expand('%:t:r')
  let path  = dir.bname.'.vim'
  if empty(dir) || empty(bname) | return '' | endif
  return s:check_write(path) ? path : ''
endfunc

func s:get_csename()
  let dir = s:check_dir('g:csedit_str_dump_dir')
  if empty(dir) | return '' | endif
  let scheme = split(execute('colorscheme'),"\n")[0]
  let scheme = empty(scheme) ? 'no_name' : scheme
  let bname = g:csedit_str_dump_prefix.scheme
  let path = dir.bname.'.csed'
  let path = s:__info.input_path('save to: ', path)
  if empty(path) | return '' | endif
  return s:check_overwrite(path) ? path : ''
endfunc

func s:check_dir( val_dir )
  exec 'let dir='.a:val_dir
  if type(dir)!=v:t_string
    return s:__info.error(a:val_dir.' must be a string.')
  endif
  let dir = dir=~'\~' ? expand(dir) : dir
  if empty(dir) || !isdirectory(dir)
    return s:__info.error(a:val_dir.' is not a valid directory.')
  endif
  return s:add_slash(dir)
endfunc

func s:check_write(path)
  let query =
    \ s:_exists(a:path) ? '"'.a:path."\" exists.\nAre you sure to overwrite?" :
    \                     'Create file "'.a:path.'" ok?'
  return s:__info.yn( query )
endfunc

func s:check_overwrite(path)
  if !s:_exists(a:path) | return 1 | endif
  let query = '"'.a:path."\" exists.\nAre you sure to overwrite?"
  return s:__info.yn( query )
endfunc

func s:add_slash(dir)
  return empty(a:dir) ? '' : a:dir !~ '[/\\]$' ? a:dir.s:slash : a:dir
endfunc

func s:_exists(path)
  return !empty(glob(fnameescape(a:path)))
endfunc

func s:guess_slash()
  let _home = expand($HOME)
  let pos_sl = and( stridx(_home,'/'), 0xffff )
  let pos_bs = and( stridx(_home,'\'), 0xffff )
  return pos_sl<=pos_bs ? '/' : '\'
endfunc

func s:guess_colordir()
  let dir = s:add_slash(expand($HOME)).'.vim'.s:slash.'colors'.s:slash
  if s:_exists(dir) && filewritable(dir)==2 | return dir | endif
  for rtp in split(&runtimepath,',')
    let dir = s:add_slash(rtp).'colors'.s:slash
    if s:_exists(dir) &&
      \ dir !~ '\v\c[/\\]vim[0-9][0-9]+[/\\]colors[/\\]$' &&
      \ dir !~ '\v\c[/\\]bundle[/\\].*colors[/\\]$' &&
      \ filewritable(dir)==2
      return dir
    endif
  endfor
  return '.'
endfunc

call s:__()
