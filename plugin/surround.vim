" surround.vim - Surroundings
" Maintainer:   Tim Pope <vimNOSPAM@tpope.info>
" $Id$
" Help is below; it may be read here, or :call SurroundHelp() to install it as
" a help file.

" *surround.txt*  Plugin for deleting, changing, and adding "surroundings"
"
" Author:  Tim Pope <vimNOSPAM@tpope.info>        *surround-author*
" License: Same terms as Vim itself (see |license|)
"
" This plugin is only available if 'compatible' is not set.
"
" Introduction:                                   *surround*
"
" This plugin is a tool for dealing with pairs of "surroundings."  Examples
" of surroundings include parentheses, quotes, and HTML tags.  They are
" closely related to what Vim refers to as |text-objects|.  Provided
" are mappings to allow for removing, changing, and adding surroundings.
"
" Details follow on the exact semantics, but first, consider the following
" examples.  An asterisk (*) is used to denote the cursor position.
"
"   Old text                  Command     New text ~
"   "Hello *world!"           ds"         Hello world!
"   [123+4*56]/2              cs])        (123+456)/2
"   "Look ma, I'm *HTML!"     cs"<q>      <q>Look ma, I'm HTML!</q>
"   if *x>3 {                 ysW(        if ( x>3 ) {
"   my $str = *whee!;         vlllls'     my $str = 'whee!';
"
" While a few features of this plugin will work in older versions of Vim,
" Vim 7 is recommended for full functionality.
"
" Mappings:                                       *surround-mappings*
"
" Delete surroundings is *ds*.  The next character given determines the target
" to delete.  The exact nature of the target are explained in
" |surround-targets| but essentially it is the last character of a
" |text-object|.  This mapping deletes the difference between the "inner"
" object and "an" object.  This is easiest to understand with some examples:
"
"   Old text                  Command     New text ~
"   "Hello *world!"           ds"         Hello world!
"   (123+4*56)/2              ds)         123+456/2
"   <div>Yo!*</div>           dst         Yo!
"
" Change surroundings is *cs*.  It takes two arguments, a target like with
" |ds|, and a replacement.  Details about the second argument can be found
" below in |surround-replacements|.  Once again, examples are in order.
"
"   Old text                  Command     New text ~
"   "Hello *world!"           cs"'        'Hello world!'
"   "Hello *world!"           cs"<q>      <q>Hello world!</q>
"   (123+4*56)/2              cs)]        [123+456]/2
"   (123+4*56)/2              cs)[        [ 123+456 ]/2
"   <div>Yo!*</div>           cst<p>      <p>Yo!</p>
"
" *ys* takes an valid Vim motion or text object as the first object, and wraps
" it using the second argument as with |cs|.  (Unfortunately there's no good
" mnemonic for "ys").
"
"   Old text                  Command     New text ~
"   Hello w*orld!             ysiw)       Hello (world)!
"
" As a special case, *yss* operates on the current line, ignoring leading
" whitespace.
"
"   Old text                  Command     New text ~
"       Hello w*orld!         yssB            {Hello world!}
"
" In visual mode, a simple "s" with an argument wraps the selection.  This is
" referred to as the *vs* mapping, although ordinarily there will be
" additional keystrokes between the v and s.  Note that "s" already has a
" valid meaning in visual mode, but it is identical to "c".  If you have
" muscle memory for "s" and would like to use a different key, add your own
" mapping and the existing one will be disabled.
" >
"   vmap S <Plug>Vsurround
" <
" Finally, there is an experimental insert mode mapping on <C-S>.  Beware that
" this won't work on terminals with flow control (if you accidentally freeze
" your terminal, use <C-Q> to unfreeze it).  The mapping inserts the specified
" surroundings and puts the cursor between them.  If, immediately after <C-S>
" and before the replacement, carriage return is pressed, the prefix, cursor,
" and suffix will be placed on three separate lines.  If this is a common use
" case you can add a mapping for it as well.
" >
"   imap <C-Z> <Plug>Isurround<CR>
" <
" Targets:                                        *surround-targets*
"
" The |ds| and |cs| commands both take a target as their first argument.  The
" possible targets are based closely on the |text-objects| provided by Vim.
" In order for a target to work, the corresponding text object must be
" supported in the version of Vim used (Vim 7 adds several text objects, and
" thus is highly recommended).  All targets are currently just one character.
"
" Eight punctuation marks, (, ), {, }, [, ], <, and >, represent themselves
" and their counterpart.  If the opening mark is used, contained whitespace is
" also trimmed.  The targets b, B, r, and a are aliases for ), }, ], and >
" (the first two mirror Vim; the second two are completely arbitrary and
" subject to change).
"
" Three quote marks, ', ", `, represent themselves, in pairs.  They are only
" searched for on the current line.
"
" A t is a pair of HTML or XML tags.  See |tag-blocks| for details.
"
" The letters w, W, and s correspond to a |word|, a |WORD|, and a |sentence|,
" respectively.  These are special in that they have nothing do delete, and
" used with |ds| they are a no-op.  With |cs|, one could consider them a
" slight shortcut for ysi (cswb == ysiwb, more or less).
"
" A p represents a |paragraph|.  This behaves similarly to w, W, and s above;
" however, newlines are sometimes added and/or removed.
"
" Replacements:                                   *surround-replacements*
"
" A replacement argument is a single character, and is required by |cs|, |ys|,
" and |vs|.  Undefined replacement characters default to placing themselves at
" the beginning and end of the destination, which can be useful for characters
" like / and |.
"
" If either ), }, ], or > is used, the text is wrapped in the appropriate
" pair of characters.  Similar behavior can be found with (, {, and [ (but not
" <), which append an additional space to the inside.  Like with the targets
" above, b, B, r, and a are aliases for ), }, ], and >.
"
" If t or < is used, Vim prompts for an HTML/XML tag to insert.  You may
" specify attributes here and they will be stripped from the closing tag.
" End your input by pressing <CR> or >.
"
" An experimental replacement of a LaTeX environment is provided on \ and l.
" The name of the environment and any arguments will be input from a prompt.
" Opening and closing delimiters are not automatically placed on lines of
" their own; you must arrange for this to happen.  The following shows the
" resulting environment from csp\tabular}{lc<CR>
" >
"   \begin{tabular}{lc}
"   \end{tabular}
" <
" Customizing:                                    *surround-customizing*
"
" The following adds a potential replacement on "-" (ASCII 45) in PHP files.
" (To determine the ASCII code to use, :echo char2nr("-")).  The newline will
" be replaced by the original text.
" >
"   autocmd FileType php let b:surround_45 = "<?php \n ?>"
" <
" This can be used in a PHP file as in the following example.
"
"   Old text                  Command     New text ~
"   print "Hello *world!"     yss-        <?php print "Hello world!" ?>
"
" Additionally, one can use a global variable for globally available
" replacements.
" >
"   let g:surround_45 = "<% \n %>"
" <
" Issues:                                         *surround-issues*
"
" Vim could potentially get confused when deleting/changing occurs at the very
" end of the line.  Please report any repeatable instances of this.
"
" Do we need to use |inputsave()|/|inputrestore()| with the tag replacement?
"
" Customization isn't very flexible.  Need a system that allows for prompting,
" like with HTML tags and LaTeX environments.
"
" Indenting is handled haphazardly.  Need to decide the most appropriate
" behavior and implement it.  Right now one can do :let b:surround_indent = 1
" (or the global equivalent) to enable automatic re-indenting by Vim via |=|;
" should this be the default?
"
" It would be nice if |.| would work to repeat an operation.

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

function! SurroundHelp() " {{{1
    if !isdirectory(s:dir."/doc/") && exists("*mkdir")
        call mkdir(s:dir."/doc/")
    endif
    let old_hidden = &hidden
    let old_cpo = &cpo
    set hidden
    set cpo&vim
    exe "split ".fnamemodify(s:dir."/doc/surround.txt",":~")
    setlocal noai modifiable noreadonly
    %d_
    exe "0r ".fnamemodify(s:file,":~")
    norm "_d}}"_dG
    a
 vim:tw=78:ts=8:ft=help:norl:
.
    1d_
    %s/^" \=//
    silent! %s/^\(\u\l\+\):\(\s\+\*\)/\U\1 \2/
    setlocal noreadonly
    write
    bwipe!
    let &hidden = old_hidden
    let &cpo    = old_cpo
    exe "helptags ".fnamemodify(s:dir."/doc",":~")
    help surround
endfunction
let s:file = expand("<sfile>:p")
let s:dir = expand("<sfile>:p:h:h") " }}}1

" Input functions {{{1

function! s:getchar()
    let c = getchar()
    if c =~ '^\d\+$'
        let c = nr2char(c)
    endif
    return c
endfunction

function! s:inputtarget()
    let c = s:getchar()
    if c == " "
        let c = c . s:getchar()
    endif
    if c =~ "\<Esc>\|\<C-C>\|\0"
        return ""
    else
        return c
    endif
endfunction

function! s:inputreplacement()
    "echo '-- SURROUND --'
    let c = s:getchar()
    if c == " "
        let c = c . s:getchar()
    endif
    if c =~ "\<Esc>\|\<C-C>\|\0"
        return ""
    else
        return c
    endif
endfunction

function! s:beep()
    exe "norm! \<Esc>"
    return ""
endfunction

function! s:redraw()
    redraw
    return ""
endfunction

" }}}1

function! s:wrap(string,char,...) " {{{1
    let keeper = a:string
    let newchar = a:char
    let linemode = a:0 ? a:1 : 0
    let before = ""
    let after  = ""
    " Duplicate b's are just placeholders (removed)
    let pairs = "b()B{}r[]a<>"
    let extraspace = ""
    if newchar =~ '^ '
        let newchar = strpart(newchar,1)
        let extraspace = ' '
    endif
    let idx = stridx(pairs,newchar)
    if exists("b:surround_".char2nr(newchar))
        let before = matchstr(b:surround_{char2nr(newchar)},'.*\ze\n')
        let after  = matchstr(b:surround_{char2nr(newchar)},'\n\zs.*')
    elseif exists("g:surround_".char2nr(newchar))
        let before = matchstr(g:surround_{char2nr(newchar)},'.*\ze\n')
        let after  = matchstr(g:surround_{char2nr(newchar)},'\n\zs.*')
    elseif newchar ==# "p"
        let before = "\n"
        let after  = "\n\n"
    elseif newchar ==# "t" || newchar ==# "T" || newchar == "<"
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
        let default = ""
        if newchar ==# "T"
            let default = matchstr(@@,'<\zs.\{-\}\ze>')
        endif
        let tag = input("<",default)
        echo "<".substitute(tag,'>*$','>','')
        if dounmapr
            silent! cunmap <CR>
        endif
        if dounmapb
            silent! cunmap >
        endif
        if tag != ""
            let tag = substitute(tag,'>*$','','')
            let before = "<".tag.">"
            let after  = "</".substitute(tag," .*",'','').">"
        endif
    elseif newchar ==# 'l' || newchar == '\'
        let env = input('\begin','{')
        let env = env . s:closematch(env)
        echo '\begin'.env
        if env != ""
            let before = '\begin'.env
            let after  = '\end'.matchstr(env,'[^}]*').'}'
        endif
    elseif newchar ==# 'f' || newchar ==# 'F'
        let func = input('function: ')
        if func != ""
            let before = substitute(func,'($','','').'('
            let after  = ')'
            if newchar ==# 'F'
                let before = before . ' '
                let after  = ' ' . after
            endif
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
        let keeper = before.extraspace.keeper.extraspace.after
    endif
    return keeper
endfunction " }}}1

function! s:insert(...) " {{{1
    " Optional argument causes the result to appear on 3 lines, not 1
    let linemode = a:0 ? a:1 : 0
    let char = s:inputreplacement()
    while char == "\<CR>"
        " TODO: use total count for additional blank lines
        let linemode = linemode + 1
        let char = s:inputreplacement()
    endwhile
    if char == ""
        return ""
    endif
    " We could just use null, but nooooo, that won't work
    let text = s:wrap("\1",char,0)
    if linemode
        return substitute(text,'\s*\%x01\s*',"\<CR>",'')."\<C-O>O"
    else
        let len = strlen(substitute(substitute(text,'.*\%x01','',''),'.','.','g'))
        let left = ""
        while len > 0
            let len = len - 1
            let left = left . "\<Left>"
        endwhile
        return substitute(text,'\%x01','','') . left
    endif
endfunction " }}}1

function! s:reindent() " {{{1
    if (exists("b:surround_indent") || exists("g:surround_indent"))
        silent norm! '[=']
    endif
endfunction " }}}1

function! s:dosurround(...) " {{{1
    let scount = v:count1
    let char = (a:0 ? a:1 : s:inputtarget())
    let spc = ""
    if char =~ '^ '
        let char = strpart(char,1)
        let spc = 1
    endif
    let newchar = ""
    if a:0 > 1
        let newchar = a:2
        if newchar == "\<Esc>" || newchar == "\<C-C>" || newchar == ""
            return s:beep()
        endif
    endif
    let append = ""
    let original = @@
    let @@ = ""
    exe "norm d".(scount==1 ? "": scount)."i".char
    "exe "norm vi".char."d"
    let keeper = @@
    let okeeper = keeper " for reindent below
    if @@ == ""
        let @@ = original
        return ""
    endif
    let oldline = getline('.')
    let oldlnum = line('.')
    if char ==# "p"
        let append = matchstr(keeper,'\n*\%$')
        let keeper = substitute(keeper,'\n*\%$','','')
        let @@ = ""
    elseif char ==# "s" || char ==# "w" || char ==# "W"
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
    if char =~# '[\[({<T]' || spc
        let keeper = substitute(keeper,'^\s\+','','')
        let keeper = substitute(keeper,'\s\+$','','')
    endif
    if oldtail ==# rem2 && col('.') + 1 == col('$')
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
    if line('.') < oldlnum && regtype ==# "V"
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
        let keeper = s:wrap(keeper,newchar,char ==# "p") . append
    endif
    let @@ = substitute(keeper,'\n\s+\n','\n\n','g')
    call setreg('"','','a'.regtype)
    silent exe "norm! ".(a:0 < 2 ? "" : "").pcmd.'`['
    if removed =~ '\n' || okeeper =~ '\n'
        call s:reindent()
    endif
    if getline('.') =~ '^\s\+$' && keeper =~ '^\s*\n'
        silent norm! cc
    endif
    let @@ = removed
endfunction " }}}1

function! s:changesurround() " {{{1
    let a = s:inputtarget()
    if a == ""
        return s:beep()
    endif
    let b = s:inputreplacement()
    if b == ""
        return s:beep()
    endif
    call s:dosurround(a,b)
endfunction " }}}1

function! s:opfunc(type) " {{{1
    let char = s:inputreplacement()
    if char == ""
        return s:beep()
    endif
    let sel_save = &selection
    let &selection = "inclusive"
    let reg_save = @@
    let linemode = (a:type == "line" || a:type ==# "V")
    if a:type == "char"
        silent norm! `[v`]y
    elseif a:type == "line"
        silent norm! '[V']y
    elseif a:type ==# "v" || a:type ==# "V"
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
    let @@ = reg_save " s:wrap() may peek at this
    let keeper = s:wrap(keeper,char,linemode) . append
    let @@ = keeper
    silent norm! gvp`[
    if linemode
        call s:reindent()
    endif
    let @@ = reg_save
    let &selection = sel_save
endfunction " }}}1

function! s:closematch(str) " {{{1
    " Close an open (, {, [, or < on the command line.
    let tail = matchstr(a:str,'.[^\[\](){}<>]*$')
    if tail =~ '^\[.\+'
        return "]"
    elseif tail =~ '^(.\+'
        return ")"
    elseif tail =~ '^{.\+'
        return "}"
    elseif tail =~ '^<.+'
        return ">"
    else
        return ""
    endif
endfunction " }}}1

nnoremap <silent> <Plug>Dsurround  :<C-U>call <SID>dosurround(<SID>inputtarget())<CR>
nnoremap <silent> <Plug>Csurround  :<C-U>call <SID>changesurround()<CR>
nnoremap <silent> <Plug>Ysurround  :set opfunc=<SID>opfunc<CR>g@
nnoremap <silent> <Plug>Yssurround :<C-U>call <SID>opfunc(v:count1)<CR>
vnoremap <silent> <Plug>Vsurround  :<C-U>call <SID>opfunc(visualmode())<CR>
inoremap <silent> <Plug>Isurround  <C-R>=<SID>insert()<CR>

if !exists("g:surround_no_mappings") || ! g:surround_no_mappings
    nmap          ds   <Plug>Dsurround
    nmap          cs   <Plug>Csurround
    nmap          ys   <Plug>Ysurround
    nmap          yss  <Plug>Yssurround
    if !hasmapto("<Plug>Vsurround","v")
        vmap      s    <Plug>Vsurround
    endif
    if !hasmapto("<Plug>Isurround","i")
        imap     <C-S> <Plug>Isurround
    endif
endif

let &cpo = s:cpo_save

" vim:set ft=vim sw=4 sts=4 et:
