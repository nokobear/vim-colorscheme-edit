"------------------------------------------------------------
" File:        autoload/csedit.vim
" Author:      nokobear <nokobear.git at gmail dot com>
" URL:         https://github.com/nokobear/vim-colorscheme-edit
" License:     MIT license
" Last Change: 2019 Aug 26
"------------------------------------------------------------
if exists('*s:__') | finish | endif

" customize
let g:csedit_en_adjust     = get(g:,'csedit_en_adjust',1)
let g:csedit_en_auto_apply = get(g:,'csedit_en_auto_apply',0)

" ref
"------------------------------------------------------------
func s:__()
  let s:__db     = csedit#db#__()
  let s:__dumper = csedit#dumper#__()
  let s:__file   = csedit#file#__()
endfunc
func csedit#highlight()
  call s:_redraw()
endfunc
func csedit#build(...)
  let en_auto_apply = get(a:,1,g:csedit_en_auto_apply)
  call s:_build( en_auto_apply )
endfunc
func csedit#dump(...)
  let en_dumpall = get(a:,1,0)
  call s:_dump( en_dumpall )
endfunc
func csedit#version()
  return 'v1.0.0'
endfunc

" func
"------------------------------------------------------------
func s:_redraw()
  "if get(b:,'csedit_sv_changedtick',0) == b:changedtick | return | endif
  "let b:csedit_sv_changedtick = b:changedtick

  let db = s:__db.frombuf()
  if empty(db) | return | endif
  call db.builder.check_valid()

  if g:csedit_en_adjust
    call db.hi.adjust()
  endif
  call db.hi.draw()
endfunc

func s:_build(en_auto_apply)
  let db = s:__db.frombuf()
  if empty(db) | return | endif
  if !db.builder.check_valid() | return | endif

  let path = s:__file.get_vimname()
  if empty(path) | return | endif

  let txt = db.builder.build()
  "echo txt | return
  if !s:__file.write( txt, path ) | return | endif
  if a:en_auto_apply==1
    exec 'so' path
    call s:_redraw()
    echo 'Applied colorscheme'
  endif
endfunc

func s:_dump(en_dumpall)
  let path = s:__file.get_csename()
  if empty(path) | return | endif

  let txt = s:__dumper.dump( a:en_dumpall )
  "echo txt | return
  if !s:__file.write( txt, path ) | return | endif
  exec '-tabe' path
endfunc

call s:__()
