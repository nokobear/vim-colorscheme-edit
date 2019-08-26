"------------------------------------------------------------
" File:    autoload/csedit/presets/tango.vim
" Author:  nokobear <nokobear.git at gmail dot com>
" URL:     https://github.com/nokobear/vim-colorscheme-edit
" License: MIT license
"------------------------------------------------------------
if exists('s:did_load') | finish | else | let s:did_load=1 | endif

let s:_table = [
\'#000000','#cc0000','#4e9a06','#c4a000','#3f3876','#734e7a','#379897','#d2d6ce',
\'#565854','#e41339','#8ee634','#f6eb53','#7b9ccd','#a97ba7','#5de3e0','#edeeeb',
\ ]

func csedit#presets#tango#list()
  return s:_table + csedit#presets#def240#list()
endfunc
