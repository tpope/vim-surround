" surround.vim - Surroundings
" Author:       Tim Pope <http://tpo.pe/>
" Version:      2.1
" GetLatestVimScripts: 1697 1 :AutoInstall: surround.vim

if exists("g:loaded_surround") || &cp || v:version < 700
  finish
endif
let g:loaded_surround = 1

nnoremap <silent> <Plug>SurroundRepeat .
nnoremap <silent> <Plug>Dsurround  :<C-U>call surround#dosurround(surround#inputtarget())<CR>
nnoremap <silent> <Plug>Csurround  :<C-U>call surround#changesurround()<CR>
nnoremap <silent> <Plug>CSurround  :<C-U>call surround#changesurround(1)<CR>
nnoremap <expr>   <Plug>Yssurround surround#opfunc('setup').'g_'
nnoremap <expr>   <Plug>YSsurround surround#opfunc2('setup').'_'
nnoremap <expr>   <Plug>Ysurround  surround#opfunc('setup')
nnoremap <expr>   <Plug>YSurround  surround#opfunc2('setup')
vnoremap <silent> <Plug>VSurround  :<C-U>call surround#opfunc(visualmode(),visualmode() ==# 'V' ? 1 : 0)<CR>
vnoremap <silent> <Plug>VgSurround :<C-U>call surround#opfunc(visualmode(),visualmode() ==# 'V' ? 0 : 1)<CR>
inoremap <silent> <Plug>Isurround  <C-R>=surround#insert()<CR>
inoremap <silent> <Plug>ISurround  <C-R>=surround#insert(1)<CR>

if !exists("g:surround_no_mappings") || ! g:surround_no_mappings
  nmap ds  <Plug>Dsurround
  nmap cs  <Plug>Csurround
  nmap cS  <Plug>CSurround
  nmap ys  <Plug>Ysurround
  nmap yS  <Plug>YSurround
  nmap yss <Plug>Yssurround
  nmap ySs <Plug>YSsurround
  nmap ySS <Plug>YSsurround
  xmap S   <Plug>VSurround
  xmap gS  <Plug>VgSurround
  if !exists("g:surround_no_insert_mappings") || ! g:surround_no_insert_mappings
    if !hasmapto("<Plug>Isurround", "i") && "" == mapcheck("<C-S>", "i")
      imap    <C-S> <Plug>Isurround
    endif
    imap      <C-G>s <Plug>Isurround
    imap      <C-G>S <Plug>ISurround
  endif
endif

" vim:set ft=vim sw=2 sts=2 et:
