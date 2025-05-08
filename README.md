# cmp-r

Completion source for [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) using
[R.nvim](https://github.com/R-nvim/R.nvim) as backend.

## Installation

Use a plugin manager such as [lazy.nvim](https://github.com/folke/lazy.nvim)
and add `cmp-r` as a dependency of `nvim-cmp`. If you want to change any of
`cmp-r` options, you could do it while configuring `nvim-cmp`.


## Setup

Register the source for `nvim-cmp`:

```lua
require'cmp'.setup {
  sources = {
    { name = 'cmp_r' },
  }
}
```

## Configuration

### cmp-r

`cmp-r` has the following options:

  - `filetypes`: The list of file types for which the source should be enabled.
    Default: `{'r', 'rmd', 'quarto', 'rnoweb', 'rhelp'}`

  - `doc_width`: The expected maximum width of the floating documentation
    window. Valid values are between `30` and `160`. Default: `58`.

    See also the option `maxwidth` in [lspkind.nvim](https://github.com/onsails/lspkind.nvim).

  - `trigger_characters`: List of characters to trigger completion.
    Default: `{ " ", ":", "(", '"', "@", "$" }`.

  - `fun_data_1`: List of functions that receive a `data.frame` as its first
    argument and for which the `data.frame`s columns names should be
    completed. This option is overridden by `g:R_fun_data_1`. Default:
    `{'select', 'rename', 'mutate', 'filter'}`.

  - `fun_data_2`: Dictionary with parent functions as keys. The value of each
    key is a list of functions that are expected to be nested in the parent
    function which receives a data.frame as its first arguments. Column names
    of the `data.frame` are completed as arguments of the nested function.
    This option is overridden by `g:R_fun_data_1`. Default:
    `{ggplot = {'aes'}, with = {'*'}}`.

  - `quarto_intel`: Path to `yaml-intelligence-resources.json` which is part
    of `quarto` application and has all necessary information for completion
    of valid YAML options in an Quarto document. Default: `nil` (`cmp-r` will
    try to find the file).

Below is an example of how to set theses options:

```lua
require("cmp_r").setup({
  filetypes = {"r", "rmd", "quarto"},
  doc_width = 58,
  quarto_intel = "~/Downloads/quarto-1.1.251/share/editor/tools/yaml/yaml-intelligence-resources.json"
  })
```

Note: The algorithm for finding the first argument of the parent function is
very simple and would wrongly recognize `data` as the name of the
`data.frame` in the following code:

```r
ggplot(data = my_data_frame, mapping = aes(
```

### nvim-cmp

The source `cmp_r` does not require any special configuration of
`nvim-cmp` to work, and people have different preferences and workflows.
Anyway, I share below what worked best for me:

  - `cmp-r` sets the field `sortText` of completed items as "0" for
    function arguments and "9" for everything else. This means that function
    arguments will always be at the top of the list of suggestions if you put
    `cmp.config.compare.sort_text` at the top of list of compare `nvim-cmp`
    functions.

  - Install a Nerd font and install and configure your terminal emulator to
    use it. Then install [lspkind.nvim](https://github.com/onsails/lspkind.nvim)
    to have symbols representing the kind of object whose name is being completed.

  - The names of kind of objects are generic names of the LSP server protocol
    and do not match the classes of R objects. So, it is better to hide the
    names and display only the symbols.

There is a complete example of `nvim-cmp` configuration at the
[Wiki](https://github.com/R-nvim/cmp-r/wiki).

### languageserver

Since `cmp-r` and the R package `languageserver` provide completions for
the same code, and completions from the `languageserver` might be the first
ones to be displayed by `nvim-cmp`, you may want to put this in your `~/.Rprofile`:

```r
# Disable completion from the language server
options(languageserver.server_capabilities =
        list(completionProvider = FALSE, completionItemResolve = FALSE))

```
