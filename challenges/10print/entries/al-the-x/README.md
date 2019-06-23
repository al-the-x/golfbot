# `10print.zsh`

The contents of `10print.zsh` can be `source`-ed from within `zsh` or run via `zsh 10print.zsh` or typed / copied into an interactive shell session:

```zsh
$> while i=$[RANDOM%2+1] {a=(⧸ ⧹)echo -n $a[i]}|head --bytes 1000
\/\////\\\///\\\\/\////\/\\/\//\\\\///\\\\/\\\\/////\/\/\/\\/\/\\\//\////\/\\\///\/\\///\\//////\\/\\/\/\\/\\\\//\//\\/\///\\\/////\\///\//\\\/\\////\\/\\\\//\\/\/\\\/\\\\///\\/\\\/\/\\\\\/\\\\////\\/\//\\\/\\\///\/\\/\//\//\\\/\\\\///\/\\\\////\///\//\\\\\///\/////\/\\\/\\/\\/\\\//\//\/\\///\//\\/\\\\/\//\/\//\///\\\/\\\\///\\/////\///\/\//\////\\\/\/\/////\///\\/\////\\///\\///\\\\\//\///\\\\/////\\\\//\\/\//\\\/\\/\\\\/\\\/\\\/\//\\\\\\\\//\\\\\/\//\\\////\\//\/\\\///\///\\/\//\//\\//////\//\/\\\\\/\\\\//\/\\/\\/\///////\///\/\/\/\\/\/\////\/\///\\/\\\\/\///\/\\//\/\\//\\//\//\/\\/\\/\\/\///\//\\//\/\/\\\/////\\/////\\/\\\//\//\///\/\/\/\/\///\/\\\///\\\/\\\/\/\\\///\//\////\\/\/\/\/\/\\\\\/\\\\/\\/\\\\/\\\//\\\//\/\\\////\///\/\/\/\/\/\\/\\/\\\\/////\\\\///\\/////\//\/\\///\/\\\\//\/\\/\/\\\\\//\\\\///\/\\\\/\\\/\\\\/\\///\//\/\/\\\\/\\\\//\\\\\\\/\//\\\/\///\/\\//\\/\\/\//\\\/\\/\//\\\/\\//\/\\\/\/\\/\///\\/\/\/\/\/\\\/\\/\///\\///\//\\\\\/\\\/\\//\\\\\/\///\/\//\/\/\/\\///\\/\/\\
```

## Explained

I omitted whitespace wherever the shell would allow me to and avoided quoting expansions like a proper shell scripter should. Here's a brief explanation of the wizardry with links to the docs for moar larnings.

### `while LIST { LIST }`

[Alternative form of `while LIST; do LIST; done`](http://zsh.sourceforge.net/Doc/Release/Shell-Grammar.html#Alternate-Forms-For-Complex-Commands). Eliminating `; do ...; done` saves 9-10 characters; not `bash` compatible.

### `i=$[RANDOM%2+1]`

Define an integer `$i` containing a random alternation between `1` and `2` for use as an array index, because in `zsh` array indices start at 1 (why later). Breaking that down further:

- [`$[exp]` -- A string of the form `$[exp]` or `$((exp))` is substituted with the value of the arithmetic expression `exp`.](http://zsh.sourceforge.net/Doc/Release/Expansion.html#Arithmetic-Expansion) Using `$[...]` instead of the `bash`-like `$((...))` saves 2 characters. :grimace:
- [`RANDOM` -- A pseudo-random integer from 0 to 32767, newly generated each time this parameter is referenced.](http://zsh.sourceforge.net/Doc/Release/Parameters.html#index-RANDOM) If I had a way to shorthand `RANDOM` I would be a king.
- `RANDOM%2+1` -- take the remainder after dividing `RANDOM` by `2` (AKA modulo or modulus), i.e. "even or odd", add `1` to get `1` or `2`.

### `a=(⧸ ⧹)`

[Define an array variable `$a`](http://zsh.sourceforge.net/Doc/Release/Parameters.html#Array-Parameters) containing [`⧸` (Unicode Big Solidus)](https://unicode-table.com/en/29F8/) and  [`⧹` (Unicode Big Reverse Solidus)](https://unicode-table.com/en/29F9/), which can be alternated by `$i`. Of the three syntax options for arrays, `name=(value ...)` is the shortest.

I originally tried a simple `/` (solidus) and `\` (reverse solidus) but then had to escape the latter as `\\`. I had also hoped that the BIG versions would line up better on subsequent lines, but on my terminal emulator I couldn't get the line-height small enough so that the ends of the characters would touch. :/

### `echo -n`

[Write each arg on the standard output, with a space separating each one. If the `-n` flag is not present, print a newline at the end.](http://zsh.sourceforge.net/Doc/Release/Shell-Builtin-Commands.html#index-echo)

By omitting the newline, the characters are printed one after another. The line breaks at the end of the terminal window, and resizing the terminal window causes the characters to reflow. Neat.

### `$a[i]`

[Subscript the `$i` index of array `$a`](http://zsh.sourceforge.net/Doc/Release/Parameters.html#Array-Subscripts), either `⧸` or `⧹`. A more familiar form would be `${a[i]}`, but omitting the expansion braces saves me 2 characters and doesn't get confused with the closing list braces for the `while`.

### `|head --bytes 1000`

The program repeats infinitely and fills the screen rather quickly on a modern machine. Pipeing the output to `head` limited to the first 1000 bytes keeps it sane. You can run the command _without_ `head` and hit `Ctrl-C` to kill the loop at any time.
