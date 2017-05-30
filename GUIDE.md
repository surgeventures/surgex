# Programming Guide

<!-- MarkdownTOC -->

- [Code Style](#code-style)
  - [Indentation](#indentation)
  - [Line length](#line-length)
  - [Trailing white-space](#trailing-white-space)
  - [Trailing newline](#trailing-newline)
  - [Operator spacing](#operator-spacing)
  - [Comma spacing](#comma-spacing)
  - [Bracket spacing](#bracket-spacing)
  - [Negation spacing](#negation-spacing)
  - [Semicolon vs line break](#semicolon-vs-line-break)
  - [Block inner spacing](#block-inner-spacing)
  - [Block outer spacing](#block-outer-spacing)
  - [Block alignment](#block-alignment)
  - [Inline block usage](#inline-block-usage)
  - [Multi-line assignment](#multi-line-assignment)
  - [Ecto query alignment](#ecto-query-alignment)
  - [Pipe chain usage](#pipe-chain-usage)
  - [Pipe chain start](#pipe-chain-start)
  - [Large number padding](#large-number-padding)
  - [Function call parentheses](#function-call-parentheses)
  - [Macro call parentheses](#macro-call-parentheses)
  - [Moduledoc spacing](#moduledoc-spacing)
  - [Doc spacing](#doc-spacing)
  - [Alias usage](#alias-usage)
  - [Reuse directive grouping](#reuse-directive-grouping)
  - [Reuse directive scope](#reuse-directive-scope)
  - [Reuse directive placement](#reuse-directive-placement)
  - [Reuse directive order](#reuse-directive-order)
  - [Reuse directive spacing](#reuse-directive-spacing)
- [Software Design](#software-design)
- [Project Structure](#project-structure)

<!-- /MarkdownTOC -->


## Code Style

### <a name="indentation"></a>[Indentation](#indentation)

*Indentation must be done with 2 spaces.*

#### Reasoning

This is [kind of a delicate subject](https://youtu.be/SsoOG6ZeyUI), but seemingly both Elixir and
Ruby communities usually go for spaces, so it's best to stay aligned.

When it comes to linting, the use of specific number of spaces works well with the
[line length](#line-length) rule, while tabs can be expanded to arbitrary number of soft spaces in
editor, possibly ruining all the hard work put into staying in line with the column limit.

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

### <a name="line-length"></a>[Line length](#line-length)

*Lines must not be longer than 100 characters.*

#### Reasoning

The old-school 70 or 80 column limits seem way limiting for Elixir which is highly based on
indenting blocks. Considering modern screen resolutions, 100 columns should work well for anyone
with something more modern than
[this video card](https://en.wikipedia.org/wiki/Color_Graphics_Adapter).

Also, 100 column limit plays well with GitHub, CodeClimate, HexDocs and others.

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

### <a name="trailing-white-space"></a>[Trailing white-space](#trailing-white-space)

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

### <a name="trailing-newline"></a>[Trailing newline](#trailing-newline)

*Files must end with single line break.*

#### Reasoning

Many editors and version control systems consider files without final line break invalid. In git,
such last line gets highlighted with an alarming red. Like with trailing white-space, it's a bad
habit to leave such artifacts and ruin diffs for developers who save files correctly.

Reversely, leaving too many line breaks is just sloppy.

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

### <a name="operator-spacing"></a>[Operator spacing](#operator-spacing)

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

Hard to read:

```elixir
(a+b)/c
```

### <a name="comma-spacing"></a>[Comma spacing](#comma-spacing)

*Single space must be put after commas.*

#### Reasoning

It's a convention that passes through many languages - it looks good and so there's no reason to
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

### <a name="bracket-spacing"></a>[Bracket spacing](#bracket-spacing)

*There must be no space put before `}`, `]` or `)` and after `{`, `[` or `(` brackets.*

#### Reasoning

It's often tempting to add inner padding for tuples, maps, lists or function arguments to give
those constructs more space to breathe, but these structures are distinct enough to be readable
without it. They may actually be more readable without the padding, because this rule plays well
with other spacing rules (like [comma spacing](#comma-spacing) or
[operator spacing](#operator-spacing)), making expressions that combine brackets and operators have
a distinct, nicely parse-able "rhythm".

Also, when allowed to pad brackets, developers tend to add such padding inconsistently - even
between opening and ending in single line. This gets even worse once a different developer modifies
such code and has a different approach towards bracket spacing.

Lastly, it keeps pattern matchings more compact and readable, which invites developers to utilize
this wonderful Elixir feature to the fullest.

#### Examples

Preferred:

```elixir
def func(%{first: second}, [head | tail]), do: nil
```

Everything padded and unreadable (no "rhythm"):

```elixir
def func( %{ first: second }, [ head | tail ] ), do: nil
```

Inconsistencies:

```elixir
def func( %{first: second}, [head | tail]), do: nil
```

### <a name="negation-spacing"></a>[Negation spacing](#negation-spacing)

*There must be no space put before the `!` operator.*

#### Reasoning

Like with brackets, it may be tempting to pad negation to make it more visible, but in general
unary operators tend to be easier to parse when they live close to their argument. Why? Because
they usually have precedence over binary operators and padding them away from their argument makes
this precedence less apparent.

#### Examples

Preferred:

```elixir
!blocked && allowed
```

Operator precedence mixed up:

```elixir
! blocked && allowed
```

### <a name="semicolon-vs-line-break"></a>[Semicolon vs line break](#semicolon-vs-line-break)

*Semicolon (`;`) should not be used to separate statements and expressions.*

#### Reasoning

This is the most classical case when it comes to preference of vertical over horizontal alignment.
Let's just keep `;` operator for `iex` sessions and focus on code readability over doing code
minification manually - neither EVM nor GitHub will explode over that additional line break.

(Actually, ", " costs one more byte than an Unix line break but if that would be our biggest
concern then I suppose we wouldn't [prefer spaces over tabs](#indentation), so...)

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

### <a name="block-inner-spacing"></a>[Block inner spacing](#block-inner-spacing)

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

### <a name="block-outer-spacing"></a>[Block outer spacing](#block-outer-spacing)

*Indentation blocks should be surrounded with single blank line if there's surrounding code in
parent block.*

#### Reasoning

There are probably as many approaches to inserting blank lines between regular code as there are
developers, but the common aim usually is to break the heaviest parts into separate "blocks".
This rule tries to highlight one most obvious candidate for such "block" which is... an actual
block.

Since blocks are indented on the inside,
[there's no point in padding them there](#block-inner-spacing), but the outer parts of the block
(the line where `do` appears and the line where `end` appears) often include a key to a reasoning
about the whole block and are often the most important parts of the whole parent scope, so it may
be beneficial to make that part distinct.

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

### <a name="block-alignment"></a>[Block alignment](#block-alignment)

*Vertical blocks (like named functions and pattern matched function definitions) should be
preferred over horizontal blocks (like anonymous functions and `if`/`case`/`cond`).*

#### Examples

Too much crazy indentation to fit everything in one function:

```elixir
defp map_array(array) do
  array
  |> Enum.uniq
  |> Enum.map(fn array_item ->
       if is_binary(array_item) do
         array_item <> " (changed)"
       else
         array_item + 1
       end
     end)
end
```

Preferred refactor of the above:

```elixir
defp map_array(array) do
  array
  |> Enum.uniq
  |> Enum.map(&map_array_item/1)
end

defp map_array_item(array_item) when is_binary(array_item), do: array_item <> " (changed)"
defp map_array_item(array_item), do: array_item + 1
```

### <a name="inline-block-usage"></a>[Inline block usage](inline-block-usage)

Inline blocks (`do:`) should be preferred over block version for simple code that fits one line.

#### Reasoning

In case of simple and small functions, conditions etc, the inline variant of block allows to keep
code more compact and fit biggest piece of the story on the screen without losing readability.

#### Examples

Preferred:

```elixir
def add_two(number), do: number + 2
```

Wasted vertical space:

```elixir
def add_two(number) do
  number + 2
end
```

Too long (or to complex) to be inlined:

```elixir
def add_two_and_multiply_by_the_meaning_of_life_and_more(number),
  do: (number + 2) * 42 * get_more_for_this_truly_crazy_computation(number)
```

### <a name="multi-line-assignment"></a>[Multi-line assignment](#multi-line-assignment)

*When assigning a multi-line call, a new line should be inserted after the `=` and the assigned
value's calculation should be indented by one level.*

#### Reasoning

Horizontal alignment is something especially tempting in Elixir programming as there are many
operators and structures that look cool when it gets applied. In particular, pipe chains only look
good when the pipe "comes out" from the initial value. In order to achieve that in assignment,
vertical alignment is often overused.

The issue is with future-proofness of such alignment. For instance, it may easily get ruined
without developer's attention in typical find-and-replace sessions that touch the name on the left
side of `=` sign.

#### Examples

Preferred:

```elixir
user =
  User
  |> build_query()
  |> apply_scoping()
  |> Repo.one()
```

Cool yet not so future-proof:

```elixir
user = User
       |> build_query()
       |> apply_scoping()
       |> Repo.one()
```

Find-and-replace session result on the above:

```elixir
authorized_user = User
       |> build_query()
       |> apply_scoping()
       |> Repo.one()
```

### <a name="ecto-query-alignment"></a>[Ecto query alignment](#ecto-query-alignment)

*When writing multi-line Ecto queries using the `from` macro, a 2 space indentation should be
applied. An additional 2 space indentation may be added for contextual indentation of sub-keywords,
like `on` after `join`.*

#### Reasoning

Horizontal alignment is something especially tempting in Elixir programming as there are many
operators and structures that look cool when it gets applied. In particular, Ecto queries are often
written (and they do look good) when aligned to `:` after `from` macro keywords. In order to
achieve that, vertical alignment is often overused.

The issue is with future-proofness of such alignment. For instance, it'll get ruined when longer
keyword will have to be added, such as `preload` or `select` in queries with only `join` or
`where`.

It's totally possible to adhere to the 2 space indentation rule and yet to write a good looking and
readable Ecto query. In order to make things more readable, additional 2 spaces can be added for
contextual indentation of sub-keywords, like `on` after `join`.

#### Examples

Preferred:

```elixir
from users in User,
  join: credit_cards in assoc(users, :credit_card),
    on: is_nil(credit_cards.deleted_at),
  where: is_nil(users.deleted_at),
  select: users.id,
  preload: [:credit_card],
```

Cool yet not so future-proof:

```elixir
from users in User,
   join: credit_cards in assoc(users, :credit_card),
     on: is_nil(credit_cards.deleted_at),
  where: is_nil(users.deleted_at)
```

### <a name="pipe-chain-usage"></a>[Pipe chain usage](#pipe-chain-usage)

*Pipe chains must be used for only for multiple function call and never for single function calls.*

#### Reasoning

The whole point of pipe chain is that... well, it must be a *chain*. As such, single function call
does not qualify. Reversely, nesting multiple calls instead of piping them seriously limits the
readability of the code.

#### Examples

Preferred for 2 and more function calls:

```elixir
arg
|> func()
|> other_func()
```

Preferred for 1 function call:

```elixir
yet_another_func(a, b)
```

Not preferred:

```elixir
other_func(func(arg))

a |> yet_another_func(b)
```

### <a name="pipe-chain-start"></a>[Pipe chain start](#pipe-chain-start)

*Pipe chains must not be started with a function call, but with a plain value.*

#### Reasoning

The whole point of pipe chain is to push some value through the chain, end to end. In order to do
that consistently, it's best to keep away from starting chains with function calls.

This also makes it easier to see [if pipe operator should be used at all](#pipe-chain-usage) -
since chain with 2 pipes may get reduced to just 1 pipe when inproperly started with function call,
it may falsely look like a case when pipe should not be used at all.

#### Examples

Preferred:

```elixir
arg
|> func()
|> other_func()
```

Chain that lost its reason to live:

```elixir
func(arg)
|> other_func()
```

### <a name="large-number-padding"></a>[Large number padding](#large-number-padding)

*Large numbers must be padded with underscores.*

#### Reasoning

They're just more readable that way. It's one of those cases when a minimal effort can lead to
eternal gratitude from other committers.

#### Examples

Preferred:

```elixir
x = 50_000_000
```

"How many zeros is that" puzzle (hint: not as many as in previous example):

```elixir
x = 5000000
```

### <a name="function-call-parentheses"></a>[Function call parentheses](#function-call-parentheses)

*Functions should be called with parentheses.*

#### Reasoning

There's a convention in Elixir universe to make function calls distinct from macro calls by
consistently covering them with parentheses. Function calls often take part in multiple operations
in a single line or inside pipes and as such, it's just safer to mark the precedence via
parentheses.

#### Examples

Preferred:

```elixir
first() && second(arg)
```

Unreadable and with compiler warning coming up:

```elixir
first && second arg
```

### <a name="macro-call-parentheses"></a>[Macro call parentheses](#macro-call-parentheses)

*Macros should be called without parentheses.*

#### Reasoning

There's a convention in Elixir universe to make function calls distinct from macro calls by
consistently covering them with parentheses. Compared to [functions](#function-call-parentheses),
macros are often used as a DSL, with one macro invocation per line. As such, they can be safely
written (and just look better) without parentheses.

#### Examples

Preferred:

```elixir
if bool, do: nil

from t in table, select: t.id
```

Macro call that looks like a function call:

```elixir
from(t in table, select: t.id)
```

### <a name="moduledoc-spacing"></a>[Moduledoc spacing](#moduledoc-spacing)

*Single blank line must be inserted after `@moduledoc`.*

#### Reasoning

`@moduledoc` is a module-wide introduction to the module. It makes sense to give it padding and
separate it from what's coming next. The reverse looks especially bad when followed by a function
that has no `@doc` clause yet.

#### Examples

Preferred:

```elixir
defmodule SuperMod do
  @moduledoc """
  This module is seriously amazing.
  """
end
```

`@moduledoc` that pretends to be a `@doc`:

```elixir
defmodule SuperMod do
  @moduledoc """
  This module is seriously amazing.
  """
  def call, do: nil
end
```

### <a name="doc-spacing"></a>[Doc spacing](#doc-spacing)

*There must be no blank lines between `@doc` and the function definition.*

#### Reasoning

Compared to [moduledoc spacing](#moduledoc-spacing), the `@doc` clause belongs to the function
definition directly beneath it, so the lack of blank line between the two is there to make this
linkage obvious. If the blank line is there, there's a growing risk of `@doc` clause becoming
completely separated from its owner in the heat of future battles.

#### Examples

Preferred:

```elixir
@doc """
This is by far the most complex function in the universe.
"""
def func, do: nil
```

Weak linkage:

```elixir
@doc """
This is by far the most complex function in the universe.
"""

def func, do: nil
```

Broken linkage:

```elixir
@doc """
This is by far the most complex function in the universe.
"""

def non_complex_func, do: something_less_complex_than_returning_nil()

def func, do: nil
```

### <a name="alias-usage"></a>[Alias usage](#alias-usage)

*Aliases established via `alias` directive should be preferred over using full module name when
they don't override other used modules.*

#### Reasoning

Aliasing modules makes code more compact and easier to read.

#### Examples

Preferred:

```elixir
alias Toolbox.Creator

def create(params)
  params
  |> Creator.build()
  |> Creator.call()
  |> Toolbox.IO.write() # Toolbox.IO not aliased to keep stdlib's IO accessible
end
```

Not so DRY:

```elixir
def create(params)
  params
  |> Toolbox.Creator.build()
  |> Toolbox.Creator.call()
  |> Toolbox.IO.write() # Toolbox.IO not aliased to keep stdlib's IO accessible
end
```

### <a name="reuse-directive-grouping"></a>[Reuse directive grouping](#reuse-directive-grouping)

*Multiple calls to `alias`, `import`, `require` or `use` against a single module must be grouped
with `{}` parentheses, each sub-module name in a separate line, sorted alphabetically.*

#### Reasoning

The fresh new grouping ability for `alias`, `import` and `use` allows to make multiple imports
from single module shorter, more declarative and easier to comprehend. It's just a challenge to use
this convention consistently, hence this rule.

Keeping sub-module names in separate lines (even when they could fit a single line) is an
investment for the future - to have clean diffs when more modules will get added. It's also easier
to keep them in alphabetical order when they're in separate lines from day one.

#### Examples

Preferred:

```elixir
alias Toolbox.{
  Creator,
  Deletor,
  Other,
}
alias SomeOther.Mod
```

Short but not so future-proof:

```elixir
alias Toolbox.{Creator, Deletor, Other}
```

Classical but inconsistent and not so future-proof:

```elixir
alias Toolbox.Creator
alias Toolbox.Deletor
alias SomeOther.Mod
alias Toolbox.Other
```

### <a name="reuse-directive-scope"></a>[Reuse directive scope](#reuse-directive-scope)

*If a need for `alias`, `import` or `require` spans only across single function in a module (or
across a small subset of functions in otherwise large module), it should be preferred to declare it
locally on top of that function instead of globally for whole module.*

#### Reasoning

Keeping these declarations local makes them even more descriptive as to what scope is really
affected. They're also more visible, being closer to the place they're used at. The chance for
conflicts is also reduced when they're local.

#### Examples

Preferred (`alias` on `Users.User` is used in both `create` and `delete` functions so it's made
global, but `import` on `Ecto.Query` is only used in `delete` function so it's declared only
there):

```elixir
defmodule Users do
  alias Users.User

  def create(params)
    %User{}
    |> User.changeset(params)
    |> Repo.insert()
  end

  def delete(user_id) do
    import Ecto.Query

    Repo.delete_all(from users in User, where: users.id == ^user_id)
  end
end
```

Not so DRY (still, this could be OK if there would be more functions in `Users` module that
wouldn't use the `User` sub-module):

```elixir
defmodule Users do
  def create(params)
    alias Users.User

    %User{}
    |> User.changeset(params)
    |> Repo.insert()
  end

  def delete(user_id) do
    import Ecto.Query
    alias Users.User

    Repo.delete_all(from users in User, where: users.id == ^user_id)
  end
end
```

Everything a bit too public:

```elixir
defmodule Users do
  import Ecto.Query
  alias Users.User

  def create(params)
    %User{}
    |> User.changeset(params)
    |> Repo.insert()
  end

  def delete(user_id) do
    Repo.delete_all(from users in User, where: users.id == ^user_id)
  end
end
```

### <a name="reuse-directive-placement"></a>[Reuse directive placement](#reuse-directive-placement)

*Calls to `alias`, `import`, `require` or `use` should be placed on top of module or function, or
directly below `@moduledoc` in case of modules with documentation.*

#### Reasoning

Just like with [the order rule](#reuse-directive-order), this is to make finding these directives
faster when reading the code. For that reason, it's more beneficial to have such important key for
interpreting code in obvious place than attempting to have them right above the point where they're
needed (which usually ends up messed up anyway when code gets changed over time).

#### Examples

Preferred:

```elixir
defmodule Users do
  alias Users.User

  def name(user) do
    user["name"] || user.name
  end

  def delete(user_id) do
    import Ecto.Query

    user_id = String.to_integer(user_id)
    Repo.delete_all(from users in User, where: users.id == ^user_id)
  end
end
```

Cool yet not so future-proof "lazy" placement:

```elixir
defmodule Users do
  def name(user) do
    user["name"] || user.name
  end

  alias Users.User

  def delete(user_id) do
    user_id = String.to_integer(user_id)

    import Ecto.Query

    Repo.delete_all(from users in User, where: users.id == ^user_id)
  end
end
```

### <a name="reuse-directive-order"></a>[Reuse directive order](#reuse-directive-order)

*Calls to `use`, `require`, `import` and `alias` should be placed in that order.*

#### Reasoning

First of all, having any directive ordering convention definitely beats not having one, since they
are a key to parsing code and so it adds up to better code reading experience when you know exactly
where to look for an alias or import.

This specific order is an attempt to introduce more significant directives before more trivial
ones. It so happens that in case of reuse directives, the reverse alphabetical order does exactly
that, starting with `use` (which can do virtually anything with a target module) and ending with
`alias` (which is only a cosmetic change and doesn't affect the module's behavior).

#### Examples

Preferred:

```elixir
use Helpers.Thing
import Helpers.Other
alias Helpers.Tool
```

Out of order:

```elixir
alias Helpers.Tool
import Helpers.Other
use Helpers.Thing
```

### <a name="reuse-directive-spacing"></a>[Reuse directive spacing](#reuse-directive-spacing)

*Calls to `alias`, `import`, `require` or `use` should not be separated with blank lines.*

#### Reasoning

It may be tempting to separate all aliases from imports with blank line or to separate multi-line
grouped aliases from other aliases, but as long as they're properly
[placed](#reuse-directive-placement) and [ordered](#reuse-directive-order), they're readable enough
without such extra efforts. Also, as their number grows, it's more beneficial to keep them
vertically compact than needlessly padded.

#### Examples

Preferred:

```elixir
use Helpers.Thing
import Helpers.Other
alias Helpers.Subhelpers.{
  First,
  Second
}
alias Helpers.Tool
```

Too much padding (with actual code starting 3 screens below):

```elixir
use Helpers.Thing

import Helpers.Other

alias Helpers.Subhelpers.{
  First,
  Second
}

alias Helpers.Tool
```

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

