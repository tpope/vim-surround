" surround.vim - Surroundings
" Maintainer:   Tim Pope <vimNOSPAM@tpope.info>
" $Id$
"
" Usage:
"
" "ds" is a mapping which deletes the surroundings of a text object--the
" difference between the "inner" object and "an" object.  See the :help on
" text-objects for details.  This is easiest to understand with some examples;
" in the following, * represents the cursor position.
"
" Old                       Keystroke   New
" "Hello *world!"           ds"         Hello world!
" (123+4*56)/2              ds)         123+456/2
" <div>Yo!</div>            dst         Yo!
"
" "cs" does as above, but rather than remove the surroundings, it replaces
" them with something else.  It takes two arguments.  Once again, examples are
" in order.  (Details about the second argument, the replacement character,
" are below).
"
" Old                       Keystroke   New
" "Hello *world!"           cs"'        'Hello world!'
" "Hello *world!"           cs"<q>      <q>Hello world!</q>
" (123+4*56)/2              cs)]        [123+456]/2
" (123+4*56)/2              cs)[        [ 123+456 ]/2
" <div>Yo!</div>            cst<p>      <p>Yo!</p>
"
" "ys" takes a motion or text object as the first object, and wraps it using
" the second argument as with "cs".
"
" Old                       Keystroke   New
" Hello w*orld!             ysiw)       Hello (world)!
"
" As a special case, "yss" operates on the current line, ignoring leading
" whitespace.
"
" Old                       Keystroke   New
"     Hello w*orld!         yssB            {Hello world!}
"
" Finally, in visual mode, a simple "s" with an argument wraps the selection.
" Note that "s" already has a valid meaning in visual mode, but it is
" identical to "c".  If you have muscle memory for "s" and would like to use a
" different key, add your own mapping and the existing one will be disabled.
"
" vmap S <Plug>VSurround
"
" Replacements:
"
" A replacement argument is a single character.  The default behavior is to
" insert that character before and after the text.
"
" If ")", "]", "}", or ">" are used, the text is wrapped in the appropriate
" open/close pair of characters.  "(", "[", and "{" behave similarly but add
" an additional space to the inside.  "B" and "b" are synonymous with "}" and
" ")".
"
" If "t" or "<" is used, Vim prompts for an HTML/XML tag to insert.  You may
" specify attributes here and they will be stripped from the closing tag.
" End your input by pressing "<CR>" or ">".
"
" Customizing:
"
" The following adds a potential replacement on "-" (ASCII 45) in PHP files.
" (To determine the ASCII code to use, :echo char2nr("-")).  The newline will
" be replaced by the original text.
"
" autocmd FileType php let b:surround_45 = "<?php \n ?>"
"
" This can be used in a PHP file as in the following example.
"
" Old                       Keystroke   New
" print "Hello *world!"     yss-        <?php print "Hello world!" ?>
"
" Additionally, one can use a global variable for globally available
" replacements.
"
" let g:surround_45 = "<% \n %>"
"
" Issues:
"
" Vim could potentially get confused when deleting/changing occurs at the very
" end of the line.  Report any repeatable instances of this.
"
" Do we need to use inputsave() / inputrestore() with the tag replacement?
"
" Customization isn't very flexible.  Need a system that allows for prompting
" similar to with tags.
"
" Reindenting is handled haphazardly.  Need to decide the most appropriate
" behavior and implement it.

" ============================================================================

" Exit quickly when:
" - this plugin was already loaded (or disabled)
" - when 'compatible' is set
if (exists("g:loaded_surround") && g:loaded_surround) || &cp
    finish
endif
let g:loaded_surround = 1

let s:cpo_save = &cpo
set cpo&vim

function! s:wrap(string,char,...) " {{{1
    let keeper = a:string
    let newchar = a:char
    let linemode = a:0 ? a:1 : 0
    " Duplicate b's are just placeholders
    let pairs = "b()B{}b[]b<>"
    let idx = stridx(pairs,newchar)
    if exists("b:surround_".char2nr(newchar))
        let before = matchstr(b:surround_{char2nr(newchar)},'.*\ze\n')
        let after  = matchstr(b:surround_{char2nr(newchar)},'\n\zs.*')
    elseif exists("g:surround_".char2nr(newchar))
        let before = matchstr(g:surround_{char2nr(newchar)},'.*\ze\n')
        let after  = matchstr(g:surround_{char2nr(newchar)},'\n\zs.*')
    elseif newchar == "p"
        let before = "\n"
        let after  = "\n\n"
    elseif newchar == "t" || newchar == "<"
        let dounmapr = 0
        let dounmapb = 0
        if !mapcheck("<CR>","c")
            let dounmapr = 1
            cnoremap <CR> ><CR>
        endif
        if !mapcheck(">","c")
            let dounmapb= 1
            cnoremap > ><CR>
        endif
        let tag = input("<")
        if dounmapr
            silent! cunmap <CR>
        endif
        if dounmapb
            silent! cunmap >
        endif
        if tag != ""
            let tag = substitute(tag,'>$','','')
            let before = "<".tag.">"
            let after  = "</".substitute(tag," .*",'','').">"
        else
            let before = ""
            let after  = ""
        endif
    elseif idx >= 0
        let spc = (idx % 3) == 1 ? " " : ""
        let idx = idx / 3 * 3
        let before = strpart(pairs,idx+1,1) . spc
        let after  = spc . strpart(pairs,idx+2,1)
    else
        let before = newchar
        let after  = newchar
    endif
    if linemode || keeper =~ '\%^\s*\n'
        let before = substitute(before,'\s*\%$','','')
    endif
    if linemode || keeper =~ '\n\s*\%$'
        let after  = substitute(after,'\%^\s*','','')
    endif
    if linemode
        let initspaces = matchstr(keeper,'\%^\s*')
        let keeper = initspaces.before."\n".keeper."\n".initspaces.after
    else
        let keeper = before.keeper.after
    endif
    return keeper
endfunction " }}}1

function! s:dosurround(...) " {{{1
    let char = nr2char(a:0 ? a:1 : getchar())
    let newchar = a:0 > 1 ? nr2char(a:2) : ""
    if newchar == "\<Esc>" || newchar == "\<C-C>"
        return s:beep()
    endif
    let append = ""
    let original = @@
    let @@ = ""
    exe "norm di".char
    "exe "norm vi".char."d"
    let keeper = @@
    if @@ == ""
        let @@ = original
        return ""
    endif
    let oldline = getline('.')
    let oldlnum = line('.')
    if char == "p"
        let append = matchstr(keeper,'\n*\%$')
        let keeper = substitute(keeper,'\n*\%$','','')
        let @@ = ""
    elseif char == "s"
        " Do nothing
        let @@ = ""
    elseif char =~ "[\"'`]"
        exe "norm! i \<Esc>d2i".char
        let @@ = substitute(@@,' ','','')
    else
        exe "norm! da".char
    endif
    let removed = @@
    let rem2 = substitute(removed,'\n.*','','')
    let oldhead = strpart(oldline,0,strlen(oldline)-strlen(rem2))
    let oldtail = strpart(oldline,  strlen(oldline)-strlen(rem2))
    "let g:oldhead = oldhead
    "let g:oldtail = oldtail
    "let g:rem2 = rem2
    "let g:keeper = keeper
    let regtype = getregtype('"')
    if oldtail == rem2 && col('.') + 1 == col('$')
        if oldhead =~# '^\s*$' && a:0 < 2
            "let keeper = substitute(keeper,'\n\s*','\n','')
            let keeper = substitute(keeper,oldhead.'\%$','','')
            let keeper = substitute(keeper,'\%^\n'.oldhead.'\(\s*.\{-\}\)\n\s*\%$','\1','')
        endif
        let pcmd = "p"
    else
        if oldhead == "" && a:0 < 2
            let keeper = substitute(keeper,'\%^\n\(.*\)\n\%$','\1','')
        endif
        let pcmd = "P"
    endif
    if line('.') < oldlnum && regtype == "V"
        let pcmd = "p"
    endif
    if removed =~ '\n$'
        let keeper = keeper."\n"
        let removed = substitute(removed,'\n$','','')
    endif
    " Originally was done twice on purpose
    "if removed =~ '\n'
        "let keeper = keeper . "\n"
        "let removed = substitute(removed,'\n','','')
    "endif
    "let g:removed = removed
    if newchar != ""
        let keeper = s:wrap(keeper,newchar,char == "p") . append
    endif
    let @@ = substitute(keeper,'\n\s+\n','\n\n','g')
    call setreg('"','','a'.regtype)
    silent exe "norm! ".(a:0 < 2 ? "" : "").pcmd.'`['
    "if @@ =~ '\n'
        "silent norm! '[=']
    "endif
    if getline('.') =~ '^\s\+$' && keeper =~ '^\s*\n'
        silent norm! cc
    endif
    let @@ = removed
endfunction " }}}1

function! s:beep()
    exe "norm! \<Esc>"
    return ""
endfunction

function! s:opfunc(type) " {{{1
    let char = nr2char(getchar())
    let g:count = v:count1
    if char == "\<Esc>" || char == "\<C-C>"
        return s:beep()
    endif
    let sel_save = &selection
    let &selection = "inclusive"
    let reg_save = @@
    let linemode = (a:type == "line" || a:type == "V")
    if a:type == "char"
        silent norm! `[v`]y
    elseif a:type == "line"
        silent norm! '[V']y
    elseif a:type == "v" || a:type == "V"
        silent norm! gvy
    elseif a:type =~ '^\d\+$'
        silent exe 'norm! ^v'.a:type.'$hy'
    else
        let &selection = sel_save
        return s:beep()
    endif
    let keeper = @@
    let append = ""
    if linemode
        let append = matchstr(keeper,'\n*$')
        let keeper = substitute(keeper,'\n*$','','')
    else
        let append = matchstr(keeper,'\s*$')
        let keeper = substitute(keeper,'\s*$','','')
    endif
    let keeper = s:wrap(keeper,char,linemode) . append
    let @@ = keeper
    silent norm! gvp`[
    "if linemode
        "silent norm! '[=']
    "endif
    let @@ = reg_save
    let &selection = sel_save
endfunction " }}}1

function! s:yss() range
    echo a:firstline." ".a:lastline
endfunction
nnoremap <silent> <Plug>DSurround :call <SID>dosurround(getchar())<CR>
nnoremap <silent> <Plug>CSurround :call <SID>dosurround(getchar(),getchar())<CR>
nnoremap <silent>  <SID>YSurround :set opfunc=<SID>opfunc<CR>g@
nnoremap <silent> <Plug>YSurroundS :<C-U> call <SID>opfunc(v:count1)<CR>
nnoremap <script> <Plug>YSurround <SID>YSurround
vnoremap <silent> <Plug>VSurround :<C-U> call <SID>opfunc(visualmode())<CR>

nmap          ds   <Plug>DSurround
nmap          cs   <Plug>CSurround
nmap          ys   <Plug>YSurround
"nmap <script> yss  :<C-U>exe 'norm ^ys'.v:count1.'$'.nr2char(getchar())<CR>
nmap <script> yss  <SID>YSurroundS
if !hasmapto("<Plug>VSurround","v")
    vmap      s    <Plug>VSurround
endif

let &cpo = s:cpo_save

" vim:set ft=vim ff=unix ts=8 sw=4 sts=4:
