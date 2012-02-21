surround.vim
============

Surround.vim is a Vim plugin that is all about "surroundings": parentheses, 
brackets, quotes, XML tags, and more.  The plugin provides mappings to easily 
delete, change and add such surroundings in pairs.

How to Use
----------

Surround.vim may be easiest to explain by taking a look at a few examples.  

### Single character surroundings

Lets change a set of double quotes to single quotes.  Surround.vim makes this
simple with four key strokes.  Start with this bit of text:

    "Hello world!"

Move your cursor so that it is within the double quotes.  Now type the letter 
`c` (change), the letter `s` (surround), the double quote `"`, and then the 
single qoute `'`.  The double quotes instantly become single quotes.

    'Hello world!'
    
To remove the delimiters entirely, type `d` (delete), `s` (surround), and the 
single quote `'`, all together like this: `ds'`.

    Hello world!

#### Surround a text object

Now with the cursor on the word "Hello", select the word and surround
it brackets by typing: `ysiw]`. (`iw` or "inner word" is one of Vim's 
[text objects](http://vimdoc.sourceforge.net/htmldoc/motion.html#object-select),
`y` is copy or "yank", but in this case is being used to select the text object 
without changing it.)

    [Hello] world!
    
This works with other text objects like sentences `is` and paragraphs `ip`.

#### Space or no space

For pairs of surrounds, use the beginning character `[` to surround 
with some space.  Use the ending `]` to surround tightly without space.

Let's change the brackets to braces and add some space. Type: `cs]{`.

    { Hello } world!

Now wrap the entire line in parentheses without space.  Type: `yss)`.

    ({ Hello } world!)

Revert to the original text with quotes: `ds{ds)yss"`

    "Hello world!"
    
### Tag surroundings

HTML and XML tag surroundings are triggered with the `<` character, after 
which you can type the whole tag and attributes.

Lets change the quotes to the html `<q>` tag.  Type `cs'<q`, hit enter, 
and the text instantly becomes:

    <q>Hello world!</q>

When dealing with existing HTML or XML tags, we don't have to type 
out the whole tag, just use the `t` (till).  So, to go full circle, 
press `cst"` to change the `<q>` tags to quotation marks `"`:

    "Hello world!"

Emphasize hello: `ysiw<em`

    <em>Hello</em> world!

Finally, let's try out visual mode. Press a capital V (for linewise
visual mode) followed by `S<p class="important"`.

    <p class="important">
      <em>Hello</em> world!
    </p>
    
Notes
-----

This plugin is very powerful for HTML and XML editing, a niche which
currently seems underfilled in Vim land.  (As opposed to HTML/XML
*inserting*, for which many plugins are available).  Adding, changing,
and removing pairs of tags simultaneously is a breeze.

The `.` command will work with `ds`, `cs`, and `yss` if you install
[repeat.vim](https://github.com/tpope/vim-repeat).

Installation
------------

If you don't have a preferred installation method, I recommend
installing [pathogen.vim](https://github.com/tpope/vim-pathogen), and
then simply copy and paste:

    cd ~/.vim/bundle
    git clone git://github.com/tpope/vim-surround.git

Once help tags have been generated, you can view the manual with
`:help surround`.

Contributing
------------

See the contribution guidelines for
[pathogen.vim](https://github.com/tpope/vim-pathogen#readme).

Self-Promotion
--------------

Like surround.vim? Follow the repository on
[GitHub](https://github.com/tpope/vim-surround) and vote for it on
[vim.org](http://www.vim.org/scripts/script.php?script_id=1697).  And if
you're feeling especially charitable, follow [tpope](http://tpo.pe/) on
[Twitter](http://twitter.com/tpope) and
[GitHub](https://github.com/tpope).

License
-------

Copyright (c) Tim Pope.  Distributed under the same terms as Vim itself.
See `:help license`.
