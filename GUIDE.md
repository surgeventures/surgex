# Programming Guide

## Code Style

Moved to `Surgex.Guide.CodeStyle`, just like the remainder soon will.

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

