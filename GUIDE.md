# Programming Guide

## Code Style

Indentation must be done with 2 spaces.

Lines must not be longer than 100 characters.

Files must not include trailing white-space at the end of any line.

Files must end with single line break.

Single space must be put around operators. For example, `a + b` is preferred over `a+b`.

Single space must be put after commas. For example, `fn(a, b)` is preferred over `fn(a,b)`.

There must be no space put before `}`, `]` or `)` and after `{`, `[` or `(`.

There must be no space put before `!`. For example, `!a` is preferred over `! a`.

Semicolon `;` should not be used to separate statements and expressions.

Indentation blocks must never start or end with blank lines.

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

Vertical spacing should be preferred over horizontal spacing to improve readability. For example,
it's preferred to split large code to more functions instead of inventing crazy indentation.

2 space indentation should be preferred over horizontal alignment.

When assigning to a multi-line call, a new line should be inserted after the `=` and the assigned
value's calculation should be indented by one level.

Pipe chains must not be started with a function call.

Pipe chains must be used for only for multiple function call and never for single function calls.
For example, `fn(arg)` is preferred over `arg |> fn()`, but `arg |> first_fn() |> second_fn()` is
preferred over `second_fn(first_fn(arg))`.

Large numbers must be padded with underscores. For example, `50_000` is preferred over `50000`.

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

