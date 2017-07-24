defmodule Surgex.DataPipe.TableSync do
  @moduledoc """
  Extracts and transforms data from one PostgreSQL table into another.

  Refer to `Surgex.DataPipe` for usage examples.
  """

  import Ecto.Query
  alias Ecto.Adapters.SQL

  @doc """
  Synchronizes the given repository's table with data fetched using a specified query.

  The synchronization is done via a single SQL query by utilizing the `WITH` statement. It first
  executes `INSERT .. ON CONFLICT` (called "upserting") to insert and update new rows, followed by
  `DELETE .. WHERE` that removes old entries that didn't appear in the input query.

  Returns a tuple with a number of upserts (inserts + updates) and a number of deletions.
  """
  def call(repo, source, target, opts \\ [])
  def call(repo, source, target, opts) do
    table = case target do
      name when is_binary(name) -> name
      schema -> schema.__schema__(:source)
    end

    columns = Keyword.get_lazy(opts, :columns, fn ->
      target.__schema__(:fields)
    end)

    conflict_target = Keyword.get_lazy(opts, :conflict_target, fn ->
      target.__schema__(:primary_key)
    end)

    query = case(source) do
      %{select: select} when not(is_nil(select)) -> source
      _ -> select(source, ^columns)
    end

    default_opts = [
      on_conflict: :replace_all,
      conflict_target: conflict_target
    ]

    do_sync(repo, table, columns, query, Keyword.merge(default_opts, opts))
  end

  defp do_sync(repo, table, columns, query, opts) do
    delete_query_sql = "id NOT IN (SELECT id FROM upserts)"
    params = Keyword.get(opts, :params, [])
    {scoped_query, scoped_params, scoped_delete_query_sql} =
      parse_scope(opts, query, params, delete_query_sql)

    columns_sql = list_to_sql(columns)
    scoped_query_sql = query_to_sql(repo, scoped_query)
    on_conflict = parse_on_conflict(opts, columns)
    sql = (
      "WITH upserts AS (" <>
        "INSERT INTO #{table} (#{columns_sql}) (#{scoped_query_sql}) #{on_conflict} RETURNING id" <>
      "), deletions AS (" <>
        "DELETE FROM #{table} WHERE #{scoped_delete_query_sql} RETURNING id" <>
      ") SELECT " <>
        "(SELECT COUNT(id) FROM upserts), (SELECT COUNT(id) FROM deletions)"
    )

    %{rows: [[upserts, deletions]]} = apply(repo, :query!, [sql, scoped_params])

    {upserts, deletions}
  end

  # Takes existing selection Ecto query, its params and deletion SQL and modifies them in case the
  # :scope option was given. In such case, both the resulting selection query and deletion SQL will
  # be filtered to only target items within specified scope.
  defp parse_scope(opts, query, params, delete_sql) do
    case Keyword.get(opts, :scope) do
      nil ->
        {query, params, delete_sql}
      scope ->
        {
          where(query, ^scope),
          params ++ Keyword.values(scope),
          delete_sql <> (
            scope
            |> Enum.map(fn {col, val} -> " AND #{col} = #{val}" end)
            |> Enum.join()
          )
        }
    end
  end

  defp parse_on_conflict(opts, columns) do
    case Keyword.fetch(opts, :on_conflict) do
      {:ok, :replace_all} ->
        targets = Keyword.fetch!(opts, :conflict_target)
        setters = Enum.map(columns, fn col -> "#{col} = excluded.#{col}" end)
        "ON CONFLICT (#{list_to_sql(targets)}) DO UPDATE SET #{list_to_sql(setters)}"
      :error ->
        nil
    end
  end

  defp query_to_sql(repo, query) do
    {sql, _} = SQL.to_sql(:all, repo, query)
    sql
  end

  defp list_to_sql(list), do: Enum.join(list, ", ")
end
