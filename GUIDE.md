# Programming Guide

## Code Style

### S1. <a name="indentation"></a>[Indentation](#indentation)

*Indentation must be done with 2 spaces.*

#### Reasoning

This is kind of a [delicate subject](https://youtu.be/SsoOG6ZeyUI), but seemingly both Elixir and
Ruby communities mostly prefer spaces, so it's best to stay aligned.

When it comes to linting, the use of specific number of spaces works well with the line length
rule, while tabs can be expanded to arbitrary number of soft spaces in editor, possibly ruining all
the hard work put into staying in line with the column limit.

As to the number of spaces, 2 seems to be optimal to allow unconstrained module, function and block
indentation without sacrificing too many columns.

#### Examples

Preferred:

```elixir
defmodule User do
  def blocked?(user) do
    !user.confirmed || user.blocked
  end
end
```

Too deep indentation (and usual outcome of using tabs):

```elixir
defmodule User do
    def blocked?(user) do
        !user.confirmed || user.blocked
    end
end
```

Missing single space:

```elixir
defmodule User do
  def blocked?(user) do
    !user.confirmed || user.blocked
 end
end
```

### S2. <a name="line-length"></a>[Line length](#line-length)

*Lines must not be longer than 100 characters.*

#### Reasoning

The old-school 70 or 80 column limits seem way limiting for Elixir which is highly based on
indenting blocks. Considering modern screen resolutions, 100 columns should work well for anyone
with something more modern than
[this video card](https://en.wikipedia.org/wiki/Color_Graphics_Adapter).

100 column limit also works well with GitHub.

#### Examples

Preferred:

```elixir
defmodule MyProject.Accounts.User do
  def build(%{
    "first_name" => first_name,
    "last_name" => last_name,
    "email" => email,
    "phone_number" => phone_number
  }) do
    %__MODULE__{
      first_name: first_name,
      last_name: last_name,
      email: email,
      phone_number: phone_number
    }
  end
end
```

Missing line breaks before limit:

```elixir
defmodule MyProject.Accounts.User do
  def build(%{"first_name" => first_name, "last_name" => last_name, "email" => email, "phone_number" => phone_number}) do
    %__MODULE__{first_name: first_name, last_name: last_name, email: email, phone_number: phone_number}
  end
end
```

### S3. <a name="trailing-white-space"></a>[Trailing white-space](#trailing-white-space)

*Files must not include trailing white-space at the end of any line.*

#### Reasoning

Leaving white-space at the end of lines is a bad programming habit that leads to crazy diffs in
version control once developers that do it get mixed with those that don't.

Most editors can be tuned to automatically trim trailing white-space on save.

#### Examples

Preferred:

```elixir
func()
```

Hidden white-space (simulated by adding comment at the end of line):

```elixir
func()                                                                                                                                                                                                           # line end
```

### S4. <a name="trailing-newline"></a>[Trailing newline](#trailing-newline)

*Files must end with single line break.*

#### Reasoning

Many editors and version control systems consider files without final line break invalid. In git,
such last line gets highlighted with red color. Like with trailing white-space, it's a bad habit to
leave such artifacts and ruin diffs for developers who save files correctly.

Reversely, leaving too many line breaks may also ruin version control diffs.

Most editors can be tuned to automatically add single trailing line break on save.

#### Examples

Preferred:

```elixir
func()⮐

```

Missing line break:

```elixir
func()
```

Too many line breaks:

```elixir
func()⮐
⮐

```

### S5. <a name="operator-spacing"></a>[Operator spacing](#operator-spacing)

*Single space must be put around operators.*

#### Reasoning

It's a matter of keeping variable names readable and distinct in operator-intensive situations.

There should be no problem with such formatting, since long lines with operators can be easily
broken into multiple, properly indented lines.

#### Examples

Preferred:

```elixir
(a + b) / c
```

No spacing:

```elixir
(a+b)/c
```

### S6. <a name="comma-spacing"></a>[Comma spacing](#comma-spacing)

*Single space must be put after commas.*

#### Reasoning

It's a convention that passes through many languages. It looks good and so there's no reason to
make an exception for Elixir on this one.

#### Examples

Preferred:

```elixir
fn(arg, %{first: first, second: second}), do: nil
```

Three creative ways to achieve pure ugliness by omitting comma between arguments, map keys or
before inline `do`:

```elixir
fn(arg,%{first: first,second: second}),do: nil
```

### S7. <a name="bracket-spacing"></a>[Bracket spacing](#bracket-spacing)

*There must be no space put before `}`, `]` or `)` and after `{`, `[` or `(`.*

#### Reasoning

It's often tempting to add inner padding for tuples, maps, lists or function arguments to give
those constructs more space to breathe, but these structures are distinct enough to be readable
without it. Actually they may be more readable without the padding, because this rule plays well
with other spacing rules (like comma spacing or operator spacing), making expressions that combine
brackets and operators have a distinct, nicely parse-able "rhythm".

Also, when allowed to pad brackets, developers tend to add such padding inconsistently - even
between opening and ending in single line - so it's better to settle upon not doing such padding at
all.

Lastly, it keeps pattern matchings more compact and readable, which invites developers to use this
wonderful Elixir feature to the fullest.

#### Examples

Preferred:

```elixir
def func(%{first: second}, [head | tail]), do: nil
```

Everything padded and unreadable, since code has no "rhythm":

```elixir
def func( %{ first: second }, [ head | tail ] ), do: nil
```

Inconsistent padding:

```elixir
def func( %{first: second}, [head | tail]), do: nil
```

### S8. <a name="negation-spacing"></a>[Negation spacing](#negation-spacing)

*There must be no space put before `!`.*

#### Reasoning

Like with brackets, it may be tempting to pad negation to make it more visible, but in general
single argument operators tend to be easier to parse when they live close to their argument. Why?
Because they usually have precedence over two argument operators and padding them away from their
argument makes this precedence less apparent.

#### Examples

Preferred:

```elixir
!blocked && allowed
```

Operator precedence mixed up:

```elixir
! blocked && allowed
```

### S9. <a name="semicolon-vs-line-break"></a>[Semicolon vs line break](#semicolon-vs-line-break)

*Semicolon (`;`) should not be used to separate statements and expressions.*

#### Reasoning

This is the most classical case when it comes to preference of vertical over horizontal alignment.
Let's just keep `;` operator for `iex` sessions and focus on code readability over doing code
minification manually - EVM won't explode from that additional line break.

#### Examples

Preferred:

```elixir
func()
other_func()
```

`iex` session saved to file by mistake:

```elixir
func(); other_func()
```

### S10. <a name="block-inner-spacing"></a>[Block inner spacing](#block-inner-spacing)

*Indentation blocks must never start or end with blank lines.*

#### Reasoning

There's no point in adding additional vertical spacing since we already have horizontal padding
increase/decrease on block start/end.

#### Examples

Preferred:

```elixir
def parent do
  nil
end
```

Wasted line:

```elixir
def parent do

  nil
end
```

### S11. <a name="block-outer-spacing"></a>[Block outer spacing](#block-outer-spacing)

*Indentation blocks should be surrounded with single blank line if there's surrounding code in
parent block.*

#### Reasoning

There are probably as many approaches to inserting blank lines between regular code as there are
developers, but the common aim usually is to break the heaviest parts into separate "blocks".
This rule tries to highlight one most obvious candidate for such "block" which is... an actual
block.

Since blocks are indented on the inside, there's no point in padding them there, but the outer
parts of the block (the line where `do` appears and the line where `end` appears) often include a
key to a reasoning about the whole block and are often the most important parts of the whole parent
scope, so it may be benefiting to make that part distinct.

In case of Elixir it's even more important, since block openings often include non-trivial
destructuring, pattern matching, wrapping things in tuples etc.

#### Examples

Preferred (there's blank line before the `Enum.map` block since there's code
(`array = [1, 2, 3]`) in parent block, but there's no blank line after that block since there's no
more code after it):

```elixir
def parent do
  array = [1, 2, 3]

  Enum.map(array, fn number ->
    number + 1
  end)
end
```

Obfuscated block:

```elixir
def parent do
  array = [1, 2, 3]
  big_numbers = Enum.map(array, fn number ->
    number + 1
  end)
  big_numbers ++ [5, 6, 7]
end
```

### S12. <a name="block-alignment"></a>[Block alignment](#block-alignment)

*Vertical blocks (like named functions and pattern matched function definitions) should be
preferred over horizontal blocks (like anonymous functions and `if`/`case`/`cond`).*

#### Examples

Preferred:

```elixir
defp map_array(array) do
  array
  |> Enum.uniq
  |> Enum.map(&map_array_item/1)
end

defp map_array_item(array_item) when is_binary(array_item), do: array_item <> " (changed)"
defp map_array_item(array_item), do: array_item + 1
```

Too much crazy indentation to fit everything in one function:

```elixir
defp map_array(array) do
  array
  |> Enum.uniq
  |> Enum.map(fn array_item ->
       if is_string(array_item) do
         array_item <> " (changed)"
       else
         array_item + 1
       end
     end)
end
```

### S13. <a name="inline-alignment"></a>[Inline alignment](#inline-alignment)

*2 space indentation should be preferred over horizontal alignment.*

#### Reasoning

Horizontal alignment is something especially tempting in Elixir programming as there are many
operators and structures that look cool when it gets applied. Here are some examples

- pipe chains only look good when the pipe "comes out" from the initial value
- keyword lists in Ecto's `from` macro look readable when aligned to the `:` after each keyword
- tuples look compact when their content starts directly after the tuple opening

In some cases it may indeed be OK to try doing that, but in general you're better off avoiding this
syntax as it forces to invent a new indentation for each specific case and this indentation is
usually not so much future-proof as adding even a single line may force a future committer to
re-align the whole thing and ruin the diff.

#### Examples

Preferred multi-line assignment of pipe chain:

```elixir
user =
  User
  |> build_query()
  |> apply_scoping()
  |> Repo.one()
```

Cool yet not so cool pipe chain, since it will get ruined on such rare occasion as when `user`
variable will have to get renamed:

```elixir
user = User
       |> build_query()
       |> apply_scoping()
       |> Repo.one()
```

As a bonus, here's how beautiful that will look after a typical find-and-replace session:

```elixir
authorized_user = User
       |> build_query()
       |> apply_scoping()
       |> Repo.one()
```

Preferred Ecto alignment with 2 spaces (and additional 2 spaces for contextual indentation of
sub-keywords, like `on` for every `join`):

```elixir
from users in User,
  join: credit_cards in assoc(users, :credit_card),
    on: is_nil(credit_cards.deleted_at),
  where: is_nil(users.deleted_at),
  select: users.id,
  preload: [:credit_card],
```

Cool yet not so cool Ecto alignment, since it will get ruined on such rare occasion as when
`select` or `preload` will have to be added:

```elixir
from users in User,
   join: credit_cards in assoc(users, :credit_card),
     on: is_nil(credit_cards.deleted_at),
  where: is_nil(users.deleted_at)
```

### S15. <a name="pipe-chain-start"></a>[Pipe chain start](#pipe-chain-start)

*Pipe chains must not be started with a function call, but with a plain value.*

### S16. <a name="pipe-chain-usage"></a>[Pipe chain usage](#pipe-chain-usage)

*Pipe chains must be used for only for multiple function call and never for single function calls.
For example, `fn(arg)` is preferred over `arg |> fn()`, but `arg |> first_fn() |> second_fn()` is
preferred over `second_fn(first_fn(arg))`.*

### S17. <a name="large-number-padding"></a>[Large number padding](#large-number-padding)

*Large numbers must be padded with underscores. For example, `50_000` is preferred over `50000`.*

Functions should be called with parentheses. For example, `fn()` or `fn(arg)` is preferred over
`fn` or `fn arg`.

Macros should be called without parentheses. For example, `if bool` or `from t in table` is
preferred over `if(bool)` or `from(t in table)`.

Single blank line must be inserted after `@moduledoc`.

There must be no blank lines between `@doc` and the function definition.

Multiple aliases, imports or uses from single module must be grouped with `{}`.

Aliases should be preferred over using full module name when they don't override other used modules
and when they're used more than once.

If a need for `alias`, `import` or `require` spans only across single function in a module, it
should be preferred to declare it locally on top of that function instead of globally for whole
module.

Calls to `use`, `require`, `import` and `alias` should be placed in that order.

Calls to `use`, `require`, `import` and `alias` should be placed on top of module or function, or
directly below `@moduledoc` in case of modules with documentation.

Calls to `use`, `require`, `import` and `alias` should not be separated with blank lines.

Inline `do:` should be preferred over block version for simple code that fits one line.

## Software Design

Sequential variable names must respect the underscore casing. For example, `fn(a_1, a_2)` is
preferred over `fn(a1, a2)`. More meaningful names should be picked when possible.

Predicate function names should end with `?` and they must return a boolean value.

Predicate function names must not start with `is` prefix.

Multiple definitions for same function must be grouped together by not separating them with a
blank line. Otherwise, functions must be separated with a single blank line.

Functions should be grouped by their relationship rather than by "public then private". For
example, if `def a` calls `defp b` then it should be preferred to place `defp b` close to `def a`
(perhaps directly below it) instead of moving `defp b` below all other `def`s. Functions that are
called by multiple other functions may be placed after the last invocation.

Functions should not include more than one level of block nesting, like `with`/`case`/`cond`/`if`
inside other `with`/`case`/`cond`/`if`. In such case it should be preferred to extract the nested
logic to separate function.

Constructs like `with`, `case`, `cond` or `if` should be picked appropriately to their purpose,
with the simplest possible construct picked over more complex one (assuming the list above starts
with most complex ones). For example, it should be preferred to use `if` over `case` to check if
something is falsy.

The `unless` construct must never be used with `else` block. In such cases, it must be rewritten as
`if`.

The `unless` construct must never be used with negation. In such cases, it must be rewritten as
`if`.

Functions from `Enum` module should be preferred over `for` construct or other custom constructs to
accomplish basic tasks on enumerables.

In `with` constructs, the `else` block should be added only if rejected value is changed. The only
exception is in controller actions, where it may be used to express all possible output values
that may come from business logic and influence action flow. In such case, the `_` operator should
be avoided in patterns matched in `else` in order not to neglect this objective.

Exception names must have the `Error` suffix. Reversely, modules that don't call `defexception`
must not have the `Error` suffix.

Module and function names should be picked not to conflict with Elixir's standard library.

Calls to `import` custom modules should be avoided.

Pattern matching should be preferred over `.` or `[]` operators for destructuring.

Keyword lists should be preferred over maps for internal passing of options.

Tuples should be preferred over lists for internal passing of short, predefined lists.

Functions that may result in success or failure and that must pass additional data upon success or
failure should return `{:ok, ...}` and `{:error, ...}` tuples.

Modules that express single action should be named with a verb prefix and have a `def call` entry.

Modules that don't express single action, should be named with nouns instead of verbs.

Repeating module name in its function names should be avoided. For example, `User.valid?` should be
preferred over `User.user_valid?`.

Operators `and` and `or` should be preferred over `&&` and `||` when arguments are known for sure
to be booleans.

Guard-enabled functions and operators should be preferred over different means to achieve the same.

Things like module lists in multi-line aliases, routes or deps in `mix.exs` should be kept in
alphabetical order.

Tuples, lists and maps may have a trailing comma after the last item.

Controller actions and their tests should be kept in usual REST action order: `index`, `show`,
`new`, `create`, `edit`, `update` and `delete`.

Nested controllers should be preferred over custom controller actions.

Named functions should be preferred over anonymous functions.

Function pointers should be preferred over redundant anonymous functions. For example, `&func/1`
is preferred over `fn arg -> func(arg) end`.

Function pointers in `&func/arity` format should be preferred over `&func(&1)` format when there's
no need for argument modification.

When a function in a module has many functions that are private to it, then it should be extracted
into separate submodule along with its private functions.

Repeated or reusable calls to `Ecto.Query.fragment` should be extracted to custom macros.

Functions that return `nil` when fetched item is missing should be named with `get` prefix.
Functions that need to return the reason for fetch failure should be named with `fetch` prefix.
Functions that raise when item is missing should be named with `!` suffix.

Sigils `~w{a b c}` and `~w{a b c}a` should be preferred over `[]` for defining string and atom
lists.

When using `_` for unused variables, it may be named for description purposes. For example, `_user`
is preferred over just `_`.

## Project Structure

Nested module files must be placed accordingly to nesting in their name. For example,
`MyProject.Web.UserController` module must be placed in `my_project/web`.

Within a module, submodule files may be segregated into subdirectories one level deep without
changing the module name. This is handy for keeping large modules organized. For example,
`MyProject.Web.UserController` module may be placed, together with other controllers, in
`my_project/web/controllers`. Inside each subdirectory, all files may share a common suffix in
order to guarantee unique module names.

Entry points for modules with submodules should be placed inside module directory with a file name
same as module name. Modules without submodules should not be placed in separate directory. For
example, `MyProject.Accounts` module should be defined in `my_project/accounts/accounts.ex` if
there are other submodules like `MyProject.Accounts.User` and in `my_project/accounts.ex` otherwise.

Module entry points should be kept as lightweight as possible and proxy heavier business logic to
submodules.

Module entry points should be used as a place to document the module and all its public functions.

