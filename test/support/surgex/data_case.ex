defmodule Surgex.DataCase do
  @moduledoc false

  use ExUnit.CaseTemplate
  alias Ecto.Adapters.SQL.Sandbox

  alias Surgex.{
    DatabaseCleaner,
    ForeignRepo,
    Repo
  }

  using do
    quote do
      alias Surgex.{ForeignRepo, Repo}

      import Ecto
      import Ecto.{Changeset, Query}
      import Surgex.DataCase
    end
  end

  setup tags do
    :ok = Sandbox.checkout(Repo)
    :ok = Sandbox.checkout(ForeignRepo)

    unless tags[:async] do
      Sandbox.mode(Repo, {:shared, self()})
      Sandbox.mode(ForeignRepo, {:shared, self()})
    end

    if tags[:transaction] == false do
      Sandbox.mode(Repo, :auto)
      Sandbox.mode(ForeignRepo, :auto)

      on_exit(fn ->
        :ok = Sandbox.checkout(Repo)
        :ok = Sandbox.checkout(ForeignRepo)

        Sandbox.mode(Repo, {:shared, self()})
        Sandbox.mode(ForeignRepo, {:shared, self()})

        Sandbox.mode(Repo, :auto)
        Sandbox.mode(ForeignRepo, :auto)

        DatabaseCleaner.call(Repo)
        DatabaseCleaner.call(ForeignRepo)
      end)
    end

    :ok
  end
end
