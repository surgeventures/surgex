defmodule Surgex.DataPipe.Cleaner do
  @moduledoc """
  Cleans tables in a PostgreSQL database.

  ## Usage

  Here's basic example:

      Surgex.DataPipe.Cleaner.call(Repo)
      Surgex.DataPipe.Cleaner.call(Repo, method: :delete_all)
      Surgex.DataPipe.Cleaner.call(Repo, only: ~w(posts users))
      Surgex.DataPipe.Cleaner.call(Repo, only: [Post, User])

  ### Non-transactional tests

  Besides data piping scenarios, this module may come handy in tests. You may use it globally if you
  want to clean before all tests as following:

      setup do
        Surgex.DataPipe.Cleaner.call(MyProject.Repo)

        # ...

        :ok
      end


  Also, you can clean repo only after those tests that are tagged not to run in an Ecto sandbox. It
  can be achieved via the `on_exit` callback as following:

      setup do
        if tags[:sandbox] == false do
          :ok = Ecto.Adapters.SQL.Sandbox.checkout(MyProject.Repo, sandbox: false)

          on_exit(fn ->
            :ok = Ecto.Adapters.SQL.Sandbox.checkout(MyProject.Repo, sandbox: false)
            Surgex.DataPipe.Cleaner.call(MyProject.Repo)
          end)
        else
          # ...
        end

        :ok
      end

  """

  @doc """
  Cleans selected or all tables in given repo using specified method.

  ## Options

  - `method`: one of `:truncate` (default), `:delete_all`
  - `only`: only cleans specified tables (defaults to all tables)

  """
  def call(repo, opts \\ []) do
    method = Keyword.get(opts, :method, :truncate)
    tables = Keyword.get(opts, :only)

    repo
    |> get_all_tables()
    |> filter_tables(tables)
    |> clean_tables(repo, method)

    :ok
  end

  defp get_all_tables(repo) do
    import Ecto.Query

    query =
      from t in "tables",
        where: t.table_schema == "public" and t.table_type == "BASE TABLE",
        select: t.table_name

    prefixed_query = Map.put(query, :prefix, "information_schema")

    repo
    |> apply(:all, [prefixed_query])
    |> List.delete("schema_migrations")
    |> Enum.into(MapSet.new)
  end

  defp filter_tables(all_tables, nil), do: all_tables
  defp filter_tables(all_tables, selected_tables) do
    selected_tables_set =
      selected_tables
      |> Enum.map(&get_table_name/1)
      |> Enum.into(MapSet.new)

    all_tables
    |> Enum.into(MapSet.new)
    |> MapSet.intersection(selected_tables_set)
    |> MapSet.to_list
  end

  defp get_table_name(name) when is_binary(name), do: name
  defp get_table_name(schema) do
    schema.__schema__(:source)
  end

  defp clean_tables(tables, repo, :delete_all) do
    Enum.each(tables, fn table ->
      apply(repo, :delete_all, [table])
    end)
  end

  defp clean_tables(tables, repo, :truncate) do
    Enum.each(tables, fn table ->
      sql = "TRUNCATE TABLE #{table} RESTART IDENTITY CASCADE"

      apply(repo, :query!, [sql, []])
    end)
  end
end
