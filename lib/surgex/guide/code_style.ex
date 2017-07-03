defmodule Surgex.Guide.CodeStyle do
  @moduledoc """
  Basic code style and formatting guidelines.
  """

  @doc """
  Indentation must be done with 2 spaces.

  ## Reasoning

  This is [kind of a delicate subject](https://youtu.be/SsoOG6ZeyUI), but seemingly both Elixir and
  Ruby communities usually go for spaces, so it's best to stay aligned.

  When it comes to linting, the use of specific number of spaces works well with the line length
  rule, while tabs can be expanded to arbitrary number of soft spaces in editor, possibly ruining
  all the hard work put into staying in line with the column limit.

  As to the number of spaces, 2 seems to be optimal to allow unconstrained module, function and
  block indentation without sacrificing too many columns.

  ## Examples

  Preferred:

      defmodule User do
        def blocked?(user) do
          !user.confirmed || user.blocked
        end
      end

  Too deep indentation (and usual outcome of using tabs):

      defmodule User do
          def blocked?(user) do
              !user.confirmed || user.blocked
          end
      end

  Missing single space:

      defmodule User do
        def blocked?(user) do
          !user.confirmed || user.blocked
       end
      end

  """
  def indentation, do: nil

  @doc """
  Lines must not be longer than 100 characters.

  ## Reasoning

  The old-school 70 or 80 column limits seem way limiting for Elixir which is highly based on
  indenting blocks. Considering modern screen resolutions, 100 columns should work well for anyone
  with something more modern than CGA video card.

  Also, 100 column limit plays well with GitHub, CodeClimate, HexDocs and others.

  ## Examples

  Preferred:

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

  Missing line breaks before limit:

      defmodule MyProject.Accounts.User do
        def build(%{"first_name" => first_name, "last_name" => last_name, "email" => email, "phone_number" => phone_number}) do
          %__MODULE__{first_name: first_name, last_name: last_name, email: email, phone_number: phone_number}
        end
      end

  """
  def line_length, do: nil

  @doc """
  Lines must not end with trailing white-space.

  ## Reasoning

  Leaving white-space at the end of lines is a bad programming habit that leads to crazy diffs in
  version control once developers that do it get mixed with those that don't.

  Most editors can be tuned to automatically trim trailing white-space on save.

  ## Examples

  Preferred:

      func()

  Hidden white-space (simulated by adding comment at the end of line):

      func()                                                                                                                                                                                                           # line end

  """
  def trailing_whitespace, do: nil

  @doc """
  Files must end with single line break.

  ## Reasoning

  Many editors and version control systems consider files without final line break invalid. In git,
  such last line gets highlighted with an alarming red. Like with trailing white-space, it's a bad
  habit to leave such artifacts and ruin diffs for developers who save files correctly.

  Reversely, leaving too many line breaks is just sloppy.

  Most editors can be tuned to automatically add single trailing line break on save.

  ## Examples

  Preferred:

      func()⮐

  Missing line break:

      func()

  Too many line breaks:

      func()⮐
      ⮐

  """
  def trailing_newline, do: nil

  @doc """
  Single space must be put around operators.

  ## Reasoning

  It's a matter of keeping variable names readable and distinct in operator-intensive situations.

  There should be no technical problem with such formatting even in long lines, since those can be
  easily broken into multiple, properly indented lines.

  ## Examples

  Preferred:

      (a + b) / c

  Hard to read:

      (a+b)/c

  """
  def operator_spacing, do: nil

  @doc """
  Single space must be put after commas.

  ## Reasoning

  It's a convention that passes through many languages - it looks good and so there's no reason to
  make an exception for Elixir on this one.

  ## Examples

  Preferred:

      fn(arg, %{first: first, second: second}), do: nil

  Three creative ways to achieve pure ugliness by omitting comma between arguments, map keys or
  before inline `do`:

      fn(arg,%{first: first,second: second}),do: nil

  """
  def comma_spacing, do: nil

  @doc """
  There must be no space put before `}`, `]` or `)` and after `{`, `[` or `(` brackets.

  ## Reasoning

  It's often tempting to add inner padding for tuples, maps, lists or function arguments to give
  those constructs more space to breathe, but these structures are distinct enough to be readable
  without it. They may actually be more readable without the padding, because this rule plays well
  with other spacing rules (like comma spacing or operator spacing), making expressions that combine
  brackets and operators have a distinct, nicely parse-able "rhythm".

  Also, when allowed to pad brackets, developers tend to add such padding inconsistently - even
  between opening and ending in single line. This gets even worse once a different developer
  modifies such code and has a different approach towards bracket spacing.

  Lastly, it keeps pattern matchings more compact and readable, which invites developers to utilize
  this wonderful Elixir feature to the fullest.

  ## Examples

  Preferred:

      def func(%{first: second}, [head | tail]), do: nil

  Everything padded and unreadable (no "rhythm"):

      def func( %{ first: second }, [ head | tail ] ), do: nil

  Inconsistencies:

      def func( %{first: second}, [head | tail]), do: nil
  """
  def bracket_spacing, do: nil

  @doc """
  There must be no space put after the `!` operator.

  ## Reasoning

  Like with brackets, it may be tempting to pad negation to make it more visible, but in general
  unary operators tend to be easier to parse when they live close to their argument. Why? Because
  they usually have precedence over binary operators and padding them away from their argument makes
  this precedence less apparent.

  ## Examples

  Preferred:

      !blocked && allowed

  Operator precedence mixed up:

      ! blocked && allowed

  """
  def negation_spacing, do: nil

  @doc """
  `;` must not be used to separate statements and expressions.

  ## Reasoning

  This is the most classical case when it comes to preference of vertical over horizontal alignment.
  Let's just keep `;` operator for `iex` sessions and focus on code readability over doing code
  minification manually - neither EVM nor GitHub will explode over that additional line break.

  > Actually, ", " costs one more byte than an Unix line break but if that would be our biggest
  > concern then I suppose we wouldn't prefer spaces over tabs for indentation...

  ## Examples

  Preferred:

      func()
      other_func()

  `iex` session saved to file by mistake:

      func(); other_func()

  """
  def semicolon_usage, do: nil

  @doc """
  Indentation blocks must never start or end with blank lines.

  ## Reasoning

  There's no point in adding additional vertical spacing since we already have horizontal padding
  increase/decrease on block start/end.

  ## Examples

  Preferred:

      def parent do
        nil
      end

  Wasted line:

      def parent do

        nil
      end

  """
  def block_inner_spacing, do: nil

  @doc """
  Indentation blocks should be padded from surrounding code with single blank line.

  ## Reasoning

  There are probably as many approaches to inserting blank lines between regular code as there are
  developers, but the common aim usually is to break the heaviest parts into separate "blocks". This
  rule tries to highlight one most obvious candidate for such "block" which is... an actual block.

  Since blocks are indented on the inside, there's no point in padding them there, but the outer
  parts of the block (the line where `do` appears and the line where `end` appears) often include a
  key to a reasoning about the whole block and are often the most important parts of the whole
  parent scope, so it may be beneficial to make that part distinct.

  In case of Elixir it's even more important, since block openings often include non-trivial
  destructuring, pattern matching, wrapping things in tuples etc.

  ## Examples

  Preferred (there's blank line before the `Enum.map` block since there's code (`array = [1, 2, 3]`)
  in parent block, but there's no blank line after that block since there's no more code after it):

      def parent do
        array = [1, 2, 3]

        Enum.map(array, fn number ->
          number + 1
        end)
      end

  Obfuscated block:

      def parent do
        array = [1, 2, 3]
        big_numbers = Enum.map(array, fn number ->
          number + 1
        end)
        big_numbers ++ [5, 6, 7]
      end

  """
  def block_outer_spacing, do: nil

  @doc """
  Vertical blocks should be preferred over horizontal blocks.

  ## Reasoning

  There's often more than one way to achieve the same and the difference is in fitting things
  horizontally through indentation vs vertically through function composition. This rule is about
  preference of the latter over the former in order to avoid crazy indentation, have more smaller
  functions, which makes for a code easier to understand and extend.

  ## Examples

  Too much crazy indentation to fit everything in one function:

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

  Preferred refactor of the above:

      defp map_array(array) do
        array
        |> Enum.uniq
        |> Enum.map(&map_array_item/1)
      end

      defp map_array_item(array_item) when is_binary(array_item), do: array_item <> " (changed)"
      defp map_array_item(array_item), do: array_item + 1

  """
  def block_alignment, do: nil

  @doc """
  Inline blocks should be preferred for simple code that fits one line.

  ## Reasoning

  In case of simple and small functions, conditions etc, the inline variant of block allows to keep
  code more compact and fit biggest piece of the story on the screen without losing readability.

  ## Examples

  Preferred:

      def add_two(number), do: number + 2

  Wasted vertical space:

      def add_two(number) do
        number + 2
      end

  Too long (or too complex) to be inlined:

      def add_two_and_multiply_by_the_meaning_of_life_and_more(number),
        do: (number + 2) * 42 * get_more_for_this_truly_crazy_computation(number)

  """
  def inline_block_usage, do: nil

  @doc """
  Multi-line calculations should be indented by one level for assignment.

  ## Reasoning

  Horizontal alignment is something especially tempting in Elixir programming as there are many
  operators and structures that look cool when it gets applied. In particular, pipe chains only look
  good when the pipe "comes out" from the initial value. In order to achieve that in assignment,
  vertical alignment is often overused.

  The issue is with future-proofness of such alignment. For instance, it may easily get ruined
  without developer's attention in typical find-and-replace sessions that touch the name on the left
  side of `=` sign.

  Hence this rule, which is about inserting a new line after the `=` and indenting the right side
  calculation by one level.

  ## Examples

  Preferred:

      user =
        User
        |> build_query()
        |> apply_scoping()
        |> Repo.one()

  Cool yet not so future-proof:

      user = User
             |> build_query()
             |> apply_scoping()
             |> Repo.one()

  Find-and-replace session result on the above:

      authorized_user = User
             |> build_query()
             |> apply_scoping()
             |> Repo.one()
  """
  def assignment_indentation, do: nil

  @doc """
  Keywords in Ecto queries should be indented by one level (and one more for `on` after `join`).

  ## Reasoning

  Horizontal alignment is something especially tempting in Elixir programming as there are many
  operators and structures that look cool when it gets applied. In particular, Ecto queries are
  often written (and they do look good) when aligned to `:` after `from` macro keywords. In order to
  achieve that, vertical alignment is often overused.

  The issue is with future-proofness of such alignment. For instance, it'll get ruined when longer
  keyword will have to be added, such as `preload` or `select` in queries with only `join` or
  `where`.

  It's totally possible to adhere to the 2 space indentation rule and yet to write a good looking
  and readable Ecto query. In order to make things more readable, additional 2 spaces can be added
  for contextual indentation of sub-keywords, like `on` after `join`.

  ## Examples

  Preferred:

      from users in User,
        join: credit_cards in assoc(users, :credit_card),
          on: is_nil(credit_cards.deleted_at),
        where: is_nil(users.deleted_at),
        select: users.id,
        preload: [:credit_card],

  Cool yet not so future-proof:

      from users in User,
         join: credit_cards in assoc(users, :credit_card),
           on: is_nil(credit_cards.deleted_at),
        where: is_nil(users.deleted_at)

  """
  def ecto_query_indentation, do: nil

  @doc """
  Pipe chains must be used only for multiple function calls.

  ## Reasoning

  The whole point of pipe chain is that... well, it must be a *chain*. As such, single function call
  does not qualify. Reversely, nesting multiple calls instead of piping them seriously limits the
  readability of the code.

  ## Examples

  Preferred for 2 and more function calls:

      arg
      |> func()
      |> other_func()

  Preferred for 1 function call:

      yet_another_func(a, b)

  Not preferred:

      other_func(func(arg))

      a |> yet_another_func(b)

  """
  def pipe_chain_usage, do: nil

  @doc """
  Pipe chains must be started with a plain value.

  ## Reasoning

  The whole point of pipe chain is to push some value through the chain, end to end. In order to do
  that consistently, it's best to keep away from starting chains with function calls.

  This also makes it easier to see if pipe operator should be used at all - since chain with 2 pipes
  may get reduced to just 1 pipe when inproperly started with function call, it may falsely look
  like a case when pipe should not be used at all.

  ## Examples

  Preferred:

      arg
      |> func()
      |> other_func()

  Chain that lost its reason to live:

      func(arg)
      |> other_func()

  """
  def pipe_chain_start, do: nil

  @doc """
  Large numbers must be padded with underscores.

  ## Reasoning

  They're just more readable that way. It's one of those cases when a minimal effort can lead to
  eternal gratitude from other committers.

  ## Examples

  Preferred:

      x = 50_000_000

  "How many zeros is that" puzzle (hint: not as many as in previous example):

      x = 5000000

  """
  def number_padding, do: nil

  @doc """
  Functions should be called with parentheses.

  ## Reasoning

  There's a convention in Elixir universe to make function calls distinct from macro calls by
  consistently covering them with parentheses. Function calls often take part in multiple operations
  in a single line or inside pipes and as such, it's just safer to mark the precedence via
  parentheses.

  ## Examples

  Preferred:

      first() && second(arg)

  Unreadable and with compiler warning coming up:

      first && second arg

  """
  def function_call_parentheses, do: nil

  @doc """
  Macros should be called without parentheses.

  ## Reasoning

  There's a convention in Elixir universe to make function calls distinct from macro calls by
  consistently covering them with parentheses. Compared to functions, macros are often used as a
  DSL, with one macro invocation per line. As such, they can be safely written (and just look
  better) without parentheses.

  ## Examples

  Preferred:

      if bool, do: nil

      from t in table, select: t.id

  Macro call that looks like a function call:

      from(t in table, select: t.id)

  """
  def macro_call_parentheses, do: nil

@doc ~S{
Single blank line must be inserted after `@moduledoc`.

## Reasoning

`@moduledoc` is a module-wide introduction to the module. It makes sense to give it padding and
separate it from what's coming next. The reverse looks especially bad when followed by a function
that has no `@doc` clause yet.

## Examples

Preferred:

    defmodule SuperMod do
      @moduledoc """
      This module is seriously amazing.
      """

      def call, do: nil
    end

`@moduledoc` that pretends to be a `@doc`:

    defmodule SuperMod do
      @moduledoc """
      This module is seriously amazing.
      """
      def call, do: nil
    end

}
  def moduledoc_spacing, do: nil

  @doc ~s{
There must be no blank lines between `@doc` and the function definition.

## Reasoning

Compared to moduledoc spacing, the `@doc` clause belongs to the function
definition directly beneath it, so the lack of blank line between the two is there to make this
linkage obvious. If the blank line is there, there's a growing risk of `@doc` clause becoming
completely separated from its owner in the heat of future battles.

## Examples

Preferred:

    @doc """
    This is by far the most complex function in the universe.
    """
    def func, do: nil

Weak linkage:

    @doc """
    This is by far the most complex function in the universe.
    """

    def func, do: nil

Broken linkage:

    @doc """
    This is by far the most complex function in the universe.
    """

    def non_complex_func, do: something_less_complex_than_returning_nil()

    def func, do: nil

}
  def doc_spacing, do: nil

  @doc """
  Aliases should be preferred over using full module name.

  ## Reasoning

  Aliasing modules makes code more compact and easier to read. They're even more beneficial as the
  number of uses of aliased module grows.

  That's of course assuming they don't override other used modules or ones that may be used in the
  future (such as stdlib's `IO` or similar).

  ## Examples

  Preferred:

      def create(params)
        alias Toolbox.Creator

        params
        |> Creator.build()
        |> Creator.call()
        |> Toolbox.IO.write()
      end

  Not so DRY:

      def create(params)
        params
        |> Toolbox.Creator.build()
        |> Toolbox.Creator.call()
        |> Toolbox.IO.write()
      end

  Overriding standard library:

      def create(params)
        alias Toolbox.IO

        params
        |> Toolbox.Creator.build()
        |> Toolbox.Creator.call()
        |> IO.write()
      end

  """
  def alias_usage, do: nil

  @doc """
  Reuse directives against same module should be grouped with `{}` syntax and sorted A-Z.

  ## Reasoning

  The fresh new grouping feature for `alias`, `import`, `require` and `use` allows to make multiple
  reuses from single module shorter, more declarative and easier to comprehend. It's just a
  challenge to use this feature consistently, hence this rule.

  Keeping sub-module names in separate lines (even when they could fit a single line) is an
  additional investment for the future - to have clean diffs when more modules will get added. It's
  also easier to keep them in alphabetical order when they're in separate lines from day one.

  ## Examples

  Preferred:

      alias Toolbox.{
        Creator,
        Deletor,
        Other,
      }
      alias SomeOther.Mod

  Short but not so future-proof:

      alias Toolbox.{Creator, Deletor, Other}

  Classical but inconsistent and not so future-proof:

      alias Toolbox.Creator
      alias Toolbox.Deletor
      alias SomeOther.Mod
      alias Toolbox.Other

  """
  def reuse_directive_grouping, do: nil

  @doc """
  Per-function usage of reuse directives should be preferred over module-wide usage.

  ## Reasoning

  If a need for `alias`, `import` or `require` spans only across single function in a module (or
  across a small subset of functions in otherwise large module), it should be preferred to declare
  it locally on top of that function instead of globally for whole module.

  Keeping these declarations local makes them even more descriptive as to what scope is really
  affected. They're also more visible, being closer to the place they're used at. The chance for
  conflicts is also reduced when they're local.

  ## Examples

  Preferred (`alias` on `Users.User` is used in both `create` and `delete` functions so it's made
  global, but `import` on `Ecto.Query` is only used in `delete` function so it's declared only
  there):

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

  Not so DRY (still, this could be OK if there would be more functions in `Users` module that
  wouldn't use the `User` sub-module):

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

  Everything a bit too public:

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

  """
  def reuse_directive_scope, do: nil

  @doc """
  Reuse directives should be placed on top of modules or functions.

  ## Reasoning

  Calls to `alias`, `import`, `require` or `use` should be placed on top of module or function, or
  directly below `@moduledoc` in case of modules with documentation.

  Just like with the order rule, this is to make finding these directives faster when reading the
  code. For that reason, it's more beneficial to have such important key for interpreting code in
  obvious place than attempting to have them right above the point where they're needed (which
  usually ends up messed up anyway when code gets changed over time).

  ## Examples

  Preferred:

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

  Cool yet not so future-proof "lazy" placement:

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

  """
  def reuse_directive_placement, do: nil

  @doc """
  Calls to reuse directives should be placed in `use`, `require`, `import`,`alias` order.

  ## Reasoning

  First of all, having any directive ordering convention definitely beats not having one, since they
  are a key to parsing code and so it adds up to better code reading experience when you know
  exactly where to look for an alias or import.

  This specific order is an attempt to introduce more significant directives before more trivial
  ones. It so happens that in case of reuse directives, the reverse alphabetical order does exactly
  that, starting with `use` (which can do virtually anything with a target module) and ending with
  `alias` (which is only a cosmetic change and doesn't affect the module's behavior).

  ## Examples

  Preferred:

      use Helpers.Thing import Helpers.Other alias Helpers.Tool

  Out of order:

      alias Helpers.Tool
      import Helpers.Other
      use Helpers.Thing

  """
  def reuse_directive_order, do: nil

  @doc """
  Calls to reuse directives should not be separated with blank lines.

  ## Reasoning

  It may be tempting to separate all aliases from imports with blank line or to separate multi-line
  grouped aliases from other aliases, but as long as they're properly placed and ordered, they're
  readable enough without such extra efforts. Also, as their number grows, it's more beneficial to
  keep them vertically compact than needlessly padded.

  ## Examples

  Preferred:

      use Helpers.Thing
      import Helpers.Other
      alias Helpers.Subhelpers.{
        First,
        Second
      }
      alias Helpers.Tool

  Too much padding (with actual code starting N screens below):

      use Helpers.Thing

      import Helpers.Other

      alias Helpers.Subhelpers.{
        First,
        Second
      }

      alias Helpers.Tool

  """
  def reuse_directive_spacing, do: nil

  @doc """
  RESTful actions should be placed in `I S N C E U D` order in controllers and their tests.

  ## Reasoning

  It's important to establish a consistent order to make it easier to find actions and their tests,
  considering that both controller and (especially) controller test files tend to be big at times.

  This particular order (`index`, `show`, `new`, `create`, `edit`, `update`, `delete`) comes from
  the long-standing convention established by both Phoenix and, earlier, Ruby on Rails generators,
  so it should be familiar, predictable and non-surprising to existing developers.

  ## Examples

  Preferred:

      defmodule MyProject.Web.UserController do
        use MyProject.Web, :controller

        def index(_conn, _params), do: raise("Not implemented")

        def show(_conn, _params), do: raise("Not implemented")

        def new(_conn, _params), do: raise("Not implemented")

        def create(_conn, _params), do: raise("Not implemented")

        def edit(_conn, _params), do: raise("Not implemented")

        def update(_conn, _params), do: raise("Not implemented")

        def delete(_conn, _params), do: raise("Not implemented")
      end

  Different (CRUD-like) order against the convention:

      defmodule MyProject.Web.UserController do
        use MyProject.Web, :controller

        def index(_conn, _params), do: raise("Not implemented")

        def new(_conn, _params), do: raise("Not implemented")

        def create(_conn, _params), do: raise("Not implemented")

        def show(_conn, _params), do: raise("Not implemented")

        def edit(_conn, _params), do: raise("Not implemented")

        def update(_conn, _params), do: raise("Not implemented")

        def delete(_conn, _params), do: raise("Not implemented")
      end

  > The issue with CRUD order is that `index` action falls between fitting and being kind of "above"
    the *Read* section and `new`/`edit` actions fall between *Read* and *Create*/*Update* sections,
    respectively.

  """
  def restful_action_order, do: nil

@doc ~S{
Documentation in `@doc` and `@moduledoc` should start with an one-line summary sentence.

## Reasoning

This first line is treated specially by ExDoc in that it's taken as a module/function summary for
API summary listings. The period at its end is removed so that it looks good both as a summary
(without the period) and as part of a whole documentation (with a period).

The single-line limit (with up to 100 characters as per line limit rule) is there to avoid mixing
up short and very long summaries on a single listing.

It's also important to fit as precise description as possible in this single line, without
unnecessarily repeating what's already expressed in the module or function name itself.

## Examples

Preferred:

    defmodule MyProject.Accounts do
      @moduledoc """
      User account authorization and management system.
      """
    end

Too vague:

    defmodule MyProject.Accounts do
      @moduledoc """
      Accounts system.
      """
    end

Missing trailing period:

    defmodule MyProject.Accounts do
      @moduledoc """
      Accounts system
      """
    end


Missing trailing blank line:

    defmodule MyProject.Accounts do
      @moduledoc """
      User account authorization and management system.
      All functions take the `MyProject.Accounts.Input` structure as input argument.
      """
    end

}
  def doc_summary_format, do: nil

@doc ~S{
Documentation in `@doc` and `@moduledoc` should be written in ExDoc-friendly Markdown.

## Reasoning

First of all, here's what is considered an ExDoc-friendly Markdown:

- Paragraphs written with full sentences, separated by a blank line

- Headings starting from 2nd level heading (`## Biggest heading`)

- Bullet lists starting with a dash and subsequent lines indented by 2 spaces

- Bullet/ordered list items separated by a blank line

- Elixir code indented by 4 spaces to mark the code block

## Examples

Preferred:

    defmodule MyProject.Accounts do
      @moduledoc """
      User account authorization and management system.

      This module does truly amazing stuff. It's purpose is to take anything you pass its way and
      make an user out of that. It can also tell you if specific user can do specific things without
      messing the system too much.

      Here's what you can expect from this module:

      - Nicely written lists with a lot of precious information that
        get indented properly in every subsequent line

      - And that are well padded as well

      And here's an Elixir code example:

          defmodule MyProject.Accounts.User do
            @defstruct [:name, :email]
          end

      It's all beautiful, isn't it?
      """
    end

Messed up line breaks, messed up list item indentation and non ExDoc-ish code block:

    defmodule MyProject.Accounts do
      @moduledoc """
      User account authorization and management system.

      This module does truly amazing stuff. It's purpose is to take anything you pass its way and
      make an user out of that. It can also tell you if specific user can do specific things without
      messing the system too much.
      Here's what you can expect from this module:

      - Nicely written lists with a lot of precious information that
      get indented properly in every subsequent line
      - And that are well padded as well

      And here's an Elixir code example:

      ```
      defmodule MyProject.Accounts.User do
        @defstruct [:name, :email]
      end
      ```

      It's not so beautiful, is it?
      """
    end

}
  def doc_content_format, do: nil
end
