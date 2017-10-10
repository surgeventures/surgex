case Code.ensure_loaded(Ecto) do
  {:module, _} ->
    defmodule Surgex.DataPipe.TableSync do
      @moduledoc """
      Extracts and transforms data from one PostgreSQL table into another.

      ## Usage

      Refer to `Surgex.DataPipe` for a complete data pipe example.
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
          "SELECT " <> _ -> source
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
        input_scope = Keyword.get(opts, :scope)
        delete_scope = Keyword.get(opts, :delete_scope)
        scoped_query = apply_query_scope(query, input_scope)
        scoped_delete_query_sql = apply_delete_sql_scope(delete_query_sql, delete_scope || input_scope)
        columns_sql = list_to_sql(columns)
        {scoped_query_sql, params} = query_to_sql(repo, scoped_query)
        on_conflict = parse_on_conflict(
          Keyword.get(opts, :on_conflict), columns, Keyword.get(opts, :conflict_target))

        sql = (
          "WITH upserts AS (" <>
            "INSERT INTO #{table} (#{columns_sql}) (#{scoped_query_sql}) #{on_conflict} RETURNING id" <>
          "), deletions AS (" <>
            "DELETE FROM #{table} WHERE #{scoped_delete_query_sql} RETURNING id" <>
          ") SELECT " <>
            "(SELECT COUNT(id) FROM upserts), (SELECT COUNT(id) FROM deletions)"
        )

        %{rows: [[upserts, deletions]]} = apply(repo, :query!, [sql, params])

        {upserts, deletions}
      end

      defp apply_query_scope(query, nil), do: query
      defp apply_query_scope(query = %{}, scope) when is_list(scope), do: where(query, ^scope)

      defp apply_delete_sql_scope(delete_sql, nil), do: delete_sql
      defp apply_delete_sql_scope(delete_sql, scope) when is_binary(scope) do
        delete_sql <> " AND #{scope}"
      end
      defp apply_delete_sql_scope(delete_sql, scope) when is_list(scope) do
        delete_sql <> (
          scope
          |> Enum.map(fn {col, val} -> " AND #{col} = #{val}" end)
          |> Enum.join()
        )
      end

      defp parse_on_conflict(nil, _, _), do: nil
      defp parse_on_conflict(:replace_all, columns, conflict_target) do
        setters = Enum.map(columns, fn col -> "#{col} = excluded.#{col}" end)

        "ON CONFLICT (#{list_to_sql(conflict_target)}) DO UPDATE SET #{list_to_sql(setters)}"
      end

      defp query_to_sql(_repo, sql) when is_binary(sql), do: {sql, []}
      defp query_to_sql(repo, query) do
        SQL.to_sql(:all, repo, query)
      end

      defp list_to_sql(list), do: Enum.join(list, ", ")
    end

  _ ->
    nil
end
