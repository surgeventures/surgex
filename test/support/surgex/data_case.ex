defmodule Surgex.DataCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias Surgex.{ForeignRepo, Repo}

      import Ecto
      import Ecto.{Changeset, Query}
      import Surgex.DataCase
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Surgex.Repo)
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Surgex.ForeignRepo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Surgex.Repo, {:shared, self()})
      Ecto.Adapters.SQL.Sandbox.mode(Surgex.ForeignRepo, {:shared, self()})
    end

    if tags[:transaction] == false do
      Ecto.Adapters.SQL.Sandbox.mode(Surgex.Repo, :auto)
      Ecto.Adapters.SQL.Sandbox.mode(Surgex.ForeignRepo, :auto)
    end

    :ok
  end
end
