# Programming Guide

## Code style

<a name="indentation"></a>
**[Indentation](#indentation):**
Indentation must be done with 2 spaces.

<a name="line-length"></a>
**[Line length](#line-length):**
Lines must not be longer than 100 characters.

<a name="trailing-white-space"></a>
**[Trailing white space](#trailing-white-space):**
Code must not include trailing white-space at the end of any line.

<a name="trailing-newline"></a>
**[Trailing newlines](#trailing-newline):**
Code must include single line break at the end of each file.

<a name="operator-spacing"></a>
**[Operator spacing](#operator-spacing):**
Single space must be put around operators. For example, `a + b` or `a || b` is preferred over
`a+b` or `a||b`.

<a name="comma-spacing"></a>
**[Comma spacing](#comma-spacing):**
Single space must be put after commas. For example, `fn(a, b)` is preferred over `fn(a,b)`.

<a name="bracket-spacing"></a>
**[Bracket spacing](#bracket-spacing):**
There must be no space put before `}`, `]` or `)` and after `{`, `[` or `(`.

<a name="negation-spacing"></a>
**[Negation spacing](#negation-spacing):**
There must be no space put before `!`. For example, `!a` is preferred over `! a`.

<a name="sequential-names"></a>
**[Sequential names](#sequential-names):**
Sequential variable names must respect the underscore casing. For example, `fn(a_1, a_2)` is
preferred over `fn(a1, a2)`. More meaningful names should be picked when possible.

<a name="blank-lines-inside-blocks"></a>
**[Blank lines inside blocks](#blank-lines-inside-blocks):**
Indentation blocks must never start or end with blank lines.

<a name="blank-lines-around-blocks"></a>
**[Blank lines around blocks](#blank-lines-around-blocks):**
Indentation blocks should be surrounded with single blank line if there's code in parent block.
On example below, there's blank line before the `Enum.map` block since there's code
(`array = [1, 2, 3]`) in parent block, but there's no blank line after that block since there's no
more code after it.

```elixir
def parent do
  array = [1, 2, 3]

  Enum.map(array, fn number ->
    number + 1
  end)
end
```

## Project structure

<a name="module-placement"></a>
**[Module placement](#module-placement):**
Nested module files must be placed accordingly to nesting in their name. For example,
`MyProject.Web.UserController` module must be placed in `my_project/web`.

<a name="module-segregation"></a>
**[Module segregation](#module-segregation):**
Within a module, submodule files may be placed in subdirectories one level deep
without changing the module name. For example, `MyProject.Web.UserController` module
may be placed, together with other controllers, in `my_project/web/controllers`. Inside each
subdirectory, all files may share a common suffix in order to guarantee unique module names.

<a name="module-entry-point-placement"></a>
**[Module entry point placement](#module-entry-point-placement):**
Module entry points for modules with submodules should be placed inside module directory with a
file name same as module name. For example, `MyProject.Accounts` module should be defined in
`my_project/accounts/accounts.ex` (and in `my_project/accounts.ex` if there are no submodules).

<a name="module-entry-point-proxy"></a>
**[Module entry point proxy](#module-entry-point-proxy):**
Module entry points should be kept as lightweight as possible and proxy heavier business logic
to submodules.

<a name="module-entry-point-comments"></a>
**[Module entry point comments](#module-entry-point-comments):**
Module entry points should be used as a place to document the module and all its public
functions.

## Software design

Nothing here yet.
