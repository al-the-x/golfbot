# `hexcode.zsh`

The contents of `hexcode.zsh` can be `source`-ed into an interactive `zsh` session or typed into an interactive session, but due to [the peculiar repeatability of `$RANDOM` in `zsh`](http://zsh.sourceforge.net/Doc/Release/Parameters.html#index-RANDOM), using `hexcode.zsh` inside a subshell will produce _the exact same value every time_:

> The values of `RANDOM` form an intentionally-repeatable pseudo-random sequence; subshells that reference `RANDOM` will result in identical pseudo-random values unless the value of `RANDOM` is referenced or seeded in the parent shell in between subshell invocations.

Since the solution itself uses a subshell via `$(...)` notation, it also attempts to take care of that problem, as long as it's not invoked from a subshell:

```zsh
$> RANDOM+=1 printf '#%s\n' $(repeat 3 {printf %02X $[RANDOM%256]})
#BC57C7

$> !!
RANDOM+=1 printf '#%s\n' $(repeat 3 {printf %02X $[RANDOM%256]})
#51DF33

$> !!
RANDOM+=1 printf '#%s\n' $(repeat 3 {printf %02X $[RANDOM%256]})
#237ADA

$> source hexcode.zsh
#BF1732

$> !!
source hexcode.zsh
#894A47

$> !!
source hexcode.zsh
#98EF1B

$> zsh hexcode.zsh
#9E1E40

$> zsh hexcode.zsh
#9E1E40

$> zsh hexcode.zsh
#9E1E40
```

## Explaned

### `RANDOM+=1`

As above: ["subshells that reference `RANDOM` will result in identical pseudo-random values unless the value of `RANDOM` is referenced or seeded in the parent shell in between subshell invocations."](http://zsh.sourceforge.net/Doc/Release/Parameters.html#index-RANDOM) Assigning back onto the `RANDOM` variable re-seeds the Random Number Generator (RNG) in `zsh`; _incrementing the value_ is way shorter than `RANDOM=$RANDOM`.

### `printf '#%s\n'`

[The `printf` function in `zsh`](http://zsh.sourceforge.net/Doc/Release/Shell-Builtin-Commands.html#index-printf) works exactly like the `c` version. That's what the manual says. QED. No?

- `printf` -- Print the arguments according to the format specification. Formatting rules are [the same as used in C.](https://en.wikipedia.org/wiki/Printf_format_string#Syntax) _Can't make this stuff up, people._
- `'#%s\n'` -- the formatting string:
  - `#` -- print a literal `#` to get the `#` in `#RRGGBB`
  - `%s` -- print the argument as a string
  - `\n` -- print a newline. On my terminal, my prompt expansion rewrites back to the left-most character, so without a line break, the value was obliterated. Besides, it's polite to end output with a newline.
  
Quoting the format parameter was way more readable than using fancy escaping, as I'll explain in a sec.
  
### `$(exp)`

[A command enclosed in parentheses preceded by a dollar sign, like `$(...)`, or quoted with grave accents, like ``` `...` ```, is replaced with its standard output, with any trailing newlines deleted. If the substitution is not enclosed in double quotes, the output is broken into words using the `IFS` parameter.](http://zsh.sourceforge.net/Doc/Release/Expansion.html#Command-Substitution-1)

What the manual _doesn't_ say but expects you to know, oh great wizard, is that the command is executed in a subshell (see ["Builtins which change the shell's state"](http://zsh.sourceforge.net/Guide/zshguide03.html#l34) in the manual), as are all but the last command in a pipeline. Important to remember when paired with the `$RANDOM` caveat above.

Also, [backticks (aka "grave accents") around command substitutions are frowned on, shell-head.](https://unix.stackexchange.com/a/126928)

### `repeat TIMES LIST`

[Alternative form of `repeat WORD; do LIST; done`](http://zsh.sourceforge.net/Doc/Release/Shell-Grammar.html#Alternate-Forms-For-Complex-Commands) that saves me several characters. I could save another 2 characters by dropping the list braces, but they made it easier to read, I thought.

### `printf %02X`

I don't need the quotes in this format string because it doesn't contain any characters that `zsh` would interpret, unlike the previous format string, which contained `#`, the comment delimter. I could have escaped it as `\#`, saving the quotes and a character, but I'd have to escape the newline as `%\n`, so there goes that. What does it mean?

- `%` indicates that a format is a-coming
- `02` indicates use `0` as the padding character and pad to 2 characters wide, so values less than `10` will appear left-padded with `0`, e.g. `02`, `04`, `09`, `10`, `20`
- `X` indicates to format as hexidecimal, turning `15` into `0F`, `16` into `10` and so forth.

### `$[RANDOM%256]`

Expand to an integer between `0` and `255` by taking the modulus. Breaking that down:

- [`$[exp]` -- A string of the form `$[exp]` or `$((exp))` is substituted with the value of the arithmetic expression `exp`.](http://zsh.sourceforge.net/Doc/Release/Expansion.html#Arithmetic-Expansion) Using `$[...]` instead of the `bash`-like `$((...))` saves 2 characters. :grimace:
- [`RANDOM` -- A pseudo-random integer from 0 to 32767, newly generated each time this parameter is referenced.](http://zsh.sourceforge.net/Doc/Release/Parameters.html#index-RANDOM) If I had a way to shorthand `RANDOM` I would be a king.
- `RANDOM%256` -- take the remainder after dividing `RANDOM` by `256` (AKA modulo or modulus). Either `$RANDOM` will be evenly divisible by `256` and return `0` or it won't, returning some other number _less-than_ `256`.

Since the number passed to `printf` is between `0` and `255`, and the format is set to hexadecimal with left-padded `0`s, the output of each `repeat` will be a random value between `00` and `FF`.
