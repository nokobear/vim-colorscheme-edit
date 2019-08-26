"------------------------------------------------------------
" File:    syntax/csed.vim
" Author:  nokobear <nokobear.git at gmail dot com>
" URL:     https://github.com/nokobear/vim-colorscheme-edit
" License: MIT license
"------------------------------------------------------------
if exists('b:current_syntax') && b:current_syntax!='csed' | finish | endif

let s:_attrs = [
  \ 'bold', 'inverse', 'italic', 'nocombine', 'reverse', 'standout',
  \ 'strikethrough', 'undercurl', 'underline', 'NONE',
  \ ]
let s:_colornames = [
  \ 'Black', 'DarkBlue', 'DarkGreen', 'DarkCyan', 'DarkRed', 'DarkMagenta',
  \ 'Brown', 'DarkYellow', 'LightGray', 'LightGrey', 'Gray', 'Grey',
  \ 'DarkGray', 'DarkGrey', 'Blue', 'LightBlue', 'Green', 'LightGreen',
  \ 'Cyan', 'LightCyan', 'Red', 'LightRed', 'Magenta', 'LightMagenta',
  \ 'Yellow', 'LightYellow', 'White',
  \ ]

exe 'syntax match ScseditComment   =#.*= contains=ScseditTodo,ScseditAttr'
exe 'syntax match ScseditCommentqw =^".*='
exe 'syntax match ScseditDark      =^dark\.='
exe 'syntax match ScseditLight     =^light\.='
exe 'syntax match ScseditPreserve  =\v\c(header|footer)(begin|end):='
exe 'syntax match ScseditPreserve  =\v\c(background):='
exe 'syntax match ScseditAttr      =\v\c<('.join(s:_attrs,'|').')>='
exe 'syntax match ScseditCname     =\v\c<('.join(s:_colornames,'|').')>='
exe 'syntax match ScseditNumber    =[0-9]\+='
exe 'syntax match ScseditMinus     =-='
exe 'syntax match ScseditTodo      =CTRL-[lsd]='

if &bg=='dark'
  hi ScseditComment   guifg=#808080 guibg=NONE    ctermfg=244  ctermbg=NONE gui=NONE cterm=NONE
  hi ScseditCommentqw guifg=#2f8785 guibg=NONE    ctermfg=30   ctermbg=NONE gui=NONE cterm=NONE
  hi ScseditDark      guifg=#ff5f87 guibg=NONE    ctermfg=204  ctermbg=NONE gui=NONE cterm=NONE
  hi ScseditLight     guifg=#ff5f87 guibg=NONE    ctermfg=204  ctermbg=NONE gui=NONE cterm=NONE
  hi ScseditPreserve  guifg=#afffff guibg=NONE    ctermfg=159  ctermbg=NONE gui=NONE cterm=NONE
  hi ScseditAttr      guifg=#ff5f87 guibg=NONE    ctermfg=204  ctermbg=NONE gui=NONE cterm=NONE
  hi ScseditNumber    guifg=#ffff5f guibg=NONE    ctermfg=227  ctermbg=NONE gui=NONE cterm=NONE
  hi ScseditCname     guifg=#ffff5f guibg=NONE    ctermfg=227  ctermbg=NONE gui=NONE cterm=NONE
  hi ScseditMinus     guifg=#ffff5f guibg=NONE    ctermfg=227  ctermbg=NONE gui=NONE cterm=NONE
  hi ScseditTodo      guifg=#ffaf00 guibg=#875f87 ctermfg=214  ctermbg=96   gui=NONE cterm=NONE
else
  hi ScseditComment   guifg=#767676 guibg=NONE    ctermfg=243  ctermbg=NONE gui=NONE cterm=NONE
  hi ScseditCommentqw guifg=#5f875f guibg=NONE    ctermfg=65   ctermbg=NONE gui=NONE cterm=NONE
  hi ScseditDark      guifg=#d70000 guibg=NONE    ctermfg=160  ctermbg=NONE gui=NONE cterm=NONE
  hi ScseditLight     guifg=#d70000 guibg=NONE    ctermfg=160  ctermbg=NONE gui=NONE cterm=NONE
  hi ScseditPreserve  guifg=#4480fe guibg=NONE    ctermfg=33   ctermbg=NONE gui=NONE cterm=NONE
  hi ScseditAttr      guifg=#d70000 guibg=NONE    ctermfg=160  ctermbg=NONE gui=NONE cterm=NONE
  hi ScseditNumber    guifg=#875f00 guibg=NONE    ctermfg=94   ctermbg=NONE gui=NONE cterm=NONE
  hi ScseditCname     guifg=#875f00 guibg=NONE    ctermfg=94   ctermbg=NONE gui=NONE cterm=NONE
  hi ScseditMinus     guifg=#875f00 guibg=NONE    ctermfg=94   ctermbg=NONE gui=NONE cterm=NONE
  hi ScseditTodo      guifg=#5f5f00 guibg=#d7afaf ctermfg=58   ctermbg=181  gui=NONE cterm=NONE
endif

let b:current_syntax = 'csed'
