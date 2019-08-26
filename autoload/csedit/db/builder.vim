"------------------------------------------------------------
" File:    autoload/csedit/db/builder.vim
" Author:  nokobear <nokobear.git at gmail dot com>
" URL:     https://github.com/nokobear/vim-colorscheme-edit
" License: MIT license
"------------------------------------------------------------
if exists('*s:__') | finish | endif

" customize
let g:csedit_en_merge_gui = get(g:,'csedit_en_merge_gui',1)

" ref
"------------------------------------------------------------
func s:__()
  let s:__db_hi = csedit#db#hi#__()
  let s:__file  = csedit#file#__()
endfunc
func csedit#db#builder#__()
  if exists('s:__') | return s:__ | endif
  let s:__ = {}
  let s:__.new = funcref( 's:_new' ) " __db
  return s:__
endfunc

" constructor
func s:_new( __db )
  let __ = {}
  let __.header = ''
  let __.footer = ''
  let __.text   = ''
  let __.error  = ''
  let __.build       = funcref( 's:_build',       [a:__db] ) " -
  let __.check_valid = funcref( 's:_check_valid', [a:__db] ) " -
  return __
endfunc

" func
"------------------------------------------------------------
func s:_build( __ )
  let p = a:__.builder
  let [ p.term_dark, p.term_light, p.term_all ] = ['','','']
  let [ p.gui_dark,  p.gui_light,  p.gui_all  ] = ['','','']
  for id in a:__.keys()
    let [ tgt_term, tgt_gui ] =
      \  id =~ '^dark\.'  ? ['p.term_dark',  'p.gui_dark' ] :
      \  id =~ '^light\.' ? ['p.term_light', 'p.gui_light'] :
      \                     ['p.term_all',   'p.gui_all'  ]
    let [ cmd_term, cmd_gui ] =
      \ g:csedit_en_merge_gui ? [a:__.hi.cmd(id,'merge'),''] :
      \                      [a:__.hi.cmd(id,'term' ),a:__.hi.cmd(id,'gui')]
    exec 'let ' .tgt_term .'.=cmd_term."\n"'
    exec 'let ' .tgt_gui  .'.=cmd_gui."\n"'
  endfor
  call s:_build_text( a:__ )

  let ks = split('term_dark,term_light,term_all,gui_dark,gui_light,gui_all',',')
  for k in ks | exec 'unlet p.'.k | endfor
  return p.text
endfunc

func s:_build_text( __ )
  let bname = s:__file.get_themename()
  let p = a:__.builder
  let en_d = !empty(p.term_dark)
  let en_l = !empty(p.term_light)
  let en_merge = g:csedit_en_merge_gui
  if !en_merge || (en_d || en_l)
    let _indent    = !en_merge * 2
    let _indent_if = _indent + (en_d || en_l) * 2
    let p.term_dark  = s:_indent_cmds( p.term_dark,  _indent_if)
    let p.term_light = s:_indent_cmds( p.term_light, _indent_if)
    let p.gui_dark   = s:_indent_cmds( p.gui_dark,   _indent_if)
    let p.gui_light  = s:_indent_cmds( p.gui_light,  _indent_if)
    let p.term_all   = s:_indent_cmds( p.term_all,   _indent)
    let p.gui_all    = s:_indent_cmds( p.gui_all,    _indent)
  endif
  let set_background =
    \ !empty(p.background ) ? "set background=". p.background :
    \                         "highlight clear Normal\nset background&"
  let if_dark  =
    \ !en_d ? "" :
    \         "if &bg=='dark'\n"
  let if_light =
    \ !en_l ? "" :
    \ !en_d ? "if &bg=='light'\n" :
    \         "elseif &bg=='light'\n"
  let if_end = en_d || en_l ? "endif\n" : ""
  if !en_merge
    for v in ['if_dark', 'if_light', 'if_end']
      exec 'let '.v '=s:_indent_if('.v.')'
      "exec 'let '.v.'=empty('.v.') ? "" : "  ".'.v
    endfor
  endif
  let p.text = join([
    \  p.header,
    \  "let s:colors_name='".bname."'",
    \  set_background,"",
    \  "if !has('gui_running') && &t_Co<256",
    \  "  echomsg 'Error: colorscheme \"'.s:colors_name.'\" requires 256 colors.'",
    \  "  echomsg 'You may solve the problem with the following command.'",
    \  "  echomsg ':set t_Co=256 | colorscheme '.s:colors_name",
    \  "  finish",
    \  "endif",
    \  "highlight clear",
    \  "if exists('syntax_on')",
    \  "  syntax reset",
    \  "endif",
    \  "let g:colors_name=s:colors_name","","",
    \ ], "\n")
  if g:csedit_en_merge_gui
    let p.text .=
    \  if_dark.  p.term_dark. if_light. p.term_light. if_end. p.term_all
  else
    let p.text .= join([
    \  "if !has('gui_running')",
    \  if_dark.  p.term_dark. if_light. p.term_light. if_end. p.term_all.
    \  "else",
    \  if_dark.  p.gui_dark.  if_light. p.gui_light.  if_end. p.gui_all.
    \  "endif",
    \ ], "\n")
  endif
  let p.text .= "\n". p.footer
endfunc

func s:_indent_if( str )
  return empty(a:str) ? '' : '  '.a:str
endfunc

func s:_indent_cmds( cmds, indent )
  if !a:indent | return a:cmds | endif
  let cmds = ''
  for v in split(a:cmds,"\n")
    let cmds .= printf( '%'.a:indent."s%s\n",'',v)
  endfor
  return cmds
endfunc

func s:_check_valid( __db )
  let p = a:__db.builder
  if empty(p.error)
    return 1
  else
    echo "Error\n".p.error
    return
  endif
endfunc

call s:__()
