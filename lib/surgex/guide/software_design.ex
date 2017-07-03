defmodule Surgex.Guide.SoftwareDesign do
  @moduledoc """
  Higher level application design and engineering guidelines.
  """

  @doc """
  An `else` block should be provided for `with` when it forwards cases from external files.

  ## Reasoning

  The `with` clause allows to omit `else` entirely if its only purpose is to amend the specific
  series of matches filled between `with` and `do`. In such cases, all non-matching outputs are
  forwarded (or "bubbled up") by `with`. This is a cool feature that allows to reduce the amount of
  redundant negative matches when there's no need to amend them.

  It may however become a readability and maintenance problem when `with` calls to complex, external
  code from separate files, which makes it hard to reason about the complete set of possible
  outcomes of the whole `with` block. Therefore, it's encouraged to provide an `else` which lists
  a complete set of possible negative scenarios, even if they are not mapped to a different output.

  ## Examples

  Preferred:

      defmodule RegistrationService do
        def call(attrs) do
          with {:ok, user} <- CreateUserFromAttributesService.call(attrs),
               :ok <- SendUserWelcomeEmailService.call(user)
          do
            {:ok, user}
          else
            {:error, changeset = %Ecto.Changeset{}} -> {:error, changeset}
            {:error, :not_available} -> {:error, :not_available}
          end
        end
      end

  Unclear cross-module flow:

      defmodule RegistrationService do
        def call(attrs) do
          with {:ok, user} <- CreateUserFromAttributesService.call(attrs),
               :ok <- SendUserWelcomeEmailService.call(user)
          do
            {:ok, user}
          end
        end
      end

  """
  def with_else_usage, do: nil

  @doc """
  Matches in a `with-else` block should be placed in occurrence order.

  ## Reasoning

  Doing this will make it much easier to reason about the whole flow of the `with` block, which
  tends to be quite complex and a core of flow control.

  ## Examples

  Preferred:

      defmodule RegistrationService do
        def call(attrs) do
          with {:ok, user} <- CreateUserFromAttributesService.call(attrs),
               :ok <- SendUserWelcomeEmailService.call(user)
          do
            {:ok, user}
          else
            {:error, changeset = %Ecto.Changeset{}} -> {:error, changeset}
            {:error, :not_available} -> {:error, :not_available}
          end
        end
      end

  Unclear flow:

      defmodule RegistrationService do
        def call(attrs) do
          with {:ok, user} <- CreateUserFromAttributesService.call(attrs),
               :ok <- SendUserWelcomeEmailService.call(user)
          do
            {:ok, user}
          else
            {:error, :not_available} -> {:error, :not_available}
            {:error, changeset = %Ecto.Changeset{}} -> {:error, changeset}
          end
        end
      end

  """
  def with_else_order, do: nil

  @doc """
  Errors from extrnal contexts should be mapped to have a meaning in the current context.

  ## Reasoning

  Elixir allows to match and forward everything in `case` and `with-else` match clauses (which are
  often used to control the high level application flow) or to simply omit `else` for `with`. This
  often results in bubbling up errors, such as those in `{:error, reason}` tuples, to the next
  context in which those errors are ambiquous or not fitting the context into which they traverse.
  For instance, `{:error, :forbidden}` returned from a HTTP client is ambiguous and not fitting the
  context of a service or controller that calls it. The following questions are unanswered:

  - what exactly is forbidden?
  - why would I care if it's forbidden and not, for instance, temporarily unavailable?
  - what actually went wrong?
  - how does it map to actual input args?

  A reverse case is also possible when errors in lower contexts are intentionally named to match
  upper context expectations, breaking the separation of concerns. For instance, a service may
  return `{:error, :not_found}` or `{:error, :forbidden}` in order to implicitly fall into fallback
  controller's expectations, even though a more descriptive error naming could've been invented.

  Therefore, care should be put into naming errors in a way that matters in the contexts where
  they're born and into leveraging `case` and `with-else` constructs to re-map ambiguous or not
  fitting errors into a meaningful and fitting ones when they travel across context bounds.

  ## Examples

  Preferred:

      defmodule RegistrationService do
        def call(attrs) do
          with {:ok, user} <- CreateUserFromAttributesService.call(attrs),
               :ok <- SendUserWelcomeEmailService.call(user)
          do
            {:ok, user}
          else
            {:error, changeset = %Ecto.Changeset{}} -> {:error, :invalid_attributes, changeset}
            {:error, :not_available} -> {:error, :mailing_service_not_available}
          end
        end
      end

  Ambiguous and "out of context" errors:

      defmodule RegistrationService do
        def call(attrs) do
          with {:ok, user} <- CreateUserFromAttributesService.call(attrs),
               :ok <- SendUserWelcomeEmailService.call(user)
          do
            {:ok, user}
          else
            {:error, changeset = %Ecto.Changeset{}} -> {:error, changeset}
            {:error, :not_available} -> {:error, :not_available}
          end
        end
      end

  """
  def external_error_mapping, do: nil

  @doc """
  Non-false moduledoc should be filled only for global, context-external app modules.

  ## Reasoning

  Filling moduledoc results in adding the module to module list in the documentation. Therefore, it
  makes little sense to use it only to leave a comment about internal mechanics of specific module
  or its meaning in the context of a closed application domain. For such cases, regular comments
  should be used. This will yield a clean documentation with eagle-eye overview of the system and
  its parts that can be directly used from global or external perspective.

  ## Example

  Preferred:

      defmodule MyProject.Accounts do
        @moduledoc \"""
        Account management system.
        \"""

        @doc \"""
        Registers an user account.
        \"""
        def register(attrs) do
          MyProject.Accounts.RegistrationService.call(attrs)
        end
      end

      defmodule MyProject.Accounts.RegistrationService do
        @moduledoc false

        # Fails on occasion due to Postgres connection issue.
        # Works best on Fridays.

        def call(attrs) do
          # ...
        end
      end

  Unnecessary external-ization and comment duplication:

      defmodule MyProject.Accounts do
        @moduledoc \"""
        Account management system.
        \"""

        @doc \"""
        Registers an user account.
        \"""
        def register(attrs) do
          MyProject.Accounts.RegistrationService.call(attrs)
        end
      end

      defmodule MyProject.Accounts.RegistrationService do
        @moduledoc \"""
        Registers an user account.

        Fails on occasion due to Postgres connection issue.
        Works best on Fridays.
        \"""

        def call(attrs) do
          # ...
        end
      end

  """
  def moduledoc_usage, do: nil

  @doc """
  Usage of `import` directive at module level or without the `only` option should be avoided.

  ## Reasoning

  When importing at module level, one adds a set of foreign functions to the module that may
  conflict with existing ones. This gets worse when multiple modules are imported and their names
  start to clash with each other. When project complexity increases over time and the preference for
  imports over aliases grows, the developer will sooner or later be forced to name functions in a
  custom to-be-imported module in a way that scopes them in a target module and/or avoids naming
  conflicts with other to-be-imported modules. This results in bad function naming - names start to
  be unnecessarily long or to repeat the module name in a function name.

  When importing without the `only` option, it's unclear without visiting the source of imported
  module what exact function names and arities come from the external place. This makes the code
  harder to reason about.

  ## Examples

  Preferred:

      defmodule User do
        def full_name(%{first_name: first_name, last_name: last_name}) do
          import Enum, only: [join: 2]

          join([first_name, last_name])
        end
      end

  Too wide scope:

      defmodule User do
        import Enum, only: [join: 2]

        def full_name(%{first_name: first_name, last_name: last_name}) do
          join([first_name, last_name])
        end
      end

  Unknown imports:

      defmodule User do
        def full_name(%{first_name: first_name, last_name: last_name}) do
          import Enum

          join([first_name, last_name])
        end
      end

  """
  def import_usage, do: nil

  @doc """
  Tests should only `use` support test case modules that they need.

  ## Reasoning

  If specific test only unit tests a module without using a web request, it shouldn't use `ConnCase`
  and if it doesn't create records, it shouldn't use `DataCase`. For many tests, `ExUnit.Case` will
  be enough of a support.

  This yields more semantic test headers and avoids needlessly importing and abusing of more complex
  support files.

  ## Examples

  Preferred:

      defmodule MyProject.Web.MyControllerTest do
        use MyProject.Web.ConnCase
      end

      defmodule MyProject.MyServiceTest do
        use MyProject.DataCase
      end

      defmodule NeitherControllerNorDatabaseTest do
        use ExUnit.Case
      end

  Test support file abuse:

      defmodule MyProject.MyServiceTest do
        use MyProject.Web.ConnCase
      end

      defmodule NeitherControllerNorDatabaseTest do
        use MyProject.DataCase
      end

  """
  def test_case_usage, do: nil
end
