"------------------------------------------------------------
" File:    autoload/csedit/hi_grp.vim
" Author:  nokobear <nokobear.git at gmail dot com>
" URL:     https://github.com/nokobear/vim-colorscheme-edit
" License: MIT license
"------------------------------------------------------------
if exists('s:did_load') | finish | else | let s:did_load=1 | endif

" see:
"   help: group-name
"   help: highlight-groups

" costomize
let g:csedit_arr_dump_keys = get(g:,'csedit_arr_dump_keys', [] )

let s:_table = [
  \ 'Normal',
  \ 'Comment',
  \ 'Constant', 'String', 'Character', 'Number', 'Boolean', 'Float',
  \ 'Identifier', 'Function',
  \ 'Statement', 'Conditional', 'Operator', 'Exception',
  \ 'PreProc',
  \ 'Type', 'StorageClass',
  \ 'Special',
  \ 'Underlined',
  \ 'Ignore',
  \ 'Error',
  \ 'Todo',
  \ 'ColorColumn',
  \ 'DiffAdd', 'DiffChange', 'DiffDelete', 'DiffText',
  \ 'ErrorMsg',
  \ 'Folded',
  \ 'FoldColumn',
  \ 'IncSearch',
  \ 'LineNr',
  \ 'ModeMsg', 'MoreMsg',
  \ 'NonText',
  \ 'Pmenu', 'PmenuSel', 'PmenuSbar', 'PmenuThumb',
  \ 'Search',
  \ 'SpellBad', 'SpellCap', 'SpellLocal', 'SpellRare',
  \ 'StatusLine', 'StatusLineNC',
  \ 'TabLine', 'TabLineFill', 'TabLineSel',
  \ 'Title',
  \ 'Visual', 'VisualNOS',
  \ 'WarningMsg',
  \ 'WildMenu',
  \ 'CursorColumn',
  \ 'CursorLine', 'CursorLineNr',
  \ 'MatchParen',
  \ 'SignColumn',
  \ 'SpecialKey',
  \ 'VertSplit',
  \ ]

func csedit#hi_grp#list()
  return s:_table + g:csedit_arr_dump_keys
endfunc
