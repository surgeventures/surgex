defmodule Surgex.DataPipe.RepoProxy do
  @moduledoc """
  Proxies repo calls to appropriate repos depending on replication needs.
  """

  @read_funcs [
    aggregate: 3, aggregate: 4,
    all: 1, all: 2,
    get!: 2, get!: 3,
    get: 2, get: 3,
    get_by!: 2, get_by!: 3,
    get_by: 2, get_by: 3,
    one!: 1, one!: 2,
    one: 1, one: 2,
    preload: 2, preload: 3,
  ]

  @write_funcs [
    delete!: 1, delete!: 2,
    delete: 1, delete: 2,
    delete_all: 1, delete_all: 2,
    insert!: 1, insert!: 2,
    insert: 1, insert: 2,
    insert_all: 2, insert_all: 3,
    insert_or_update!: 1, insert_or_update!: 2,
    insert_or_update: 1, insert_or_update: 2,
    transaction: 1, transaction: 2,
    update!: 1, update!: 2,
    update: 1, update: 2,
    update_all: 2, update_all: 3,
  ]

  defmacro __using__(_) do
    proxy_ast = quote do
      @doc """
      Calls given function on one of proxied repos.
      """
      def call(func, args, opts \\ []) do
        mode = get_mode(func, length(args), opts)
        repo = get_repo(mode)

        apply(repo, func, args)
      end

      defp get_mode(func, arity, opts) do
        Keyword.get_lazy(opts, :mode, fn ->
          cond do
            Enum.member?(unquote(@read_funcs), {func, arity}) ->
              :read
            Enum.member?(unquote(@write_funcs), {func, arity}) ->
              :write
            true ->
              raise("Cannot determine default mode for func #{func}")
          end
        end)
      end

      @doc """
      Returns all proxied repos used for a given mode.
      """
      def get_repos(:all), do: get_config(:read_pool, []) ++ get_config(:write_pool, [])
      def get_repos(:read), do: get_config(:read_pool, [])
      def get_repos(:write), do: get_config(:write_pool, [])

      @doc """
      Returns one of proxied repos for a given mode.
      """
      def get_repo(mode) do
        if test_mode?() do
          :write
          |> get_repos
          |> List.first
        else
          preferred_pool = get_repos(mode)
          case length(preferred_pool) do
            0 ->
              Enum.random(get_repos(:all))
            _ ->
              Enum.random(preferred_pool)
          end
        end
      end

      defp test_mode? do
        get_config(:test_mode, false)
      end

      defp get_config(key, default \\ nil) do
        Mix.Project.config[:app]
        |> Application.get_env(__MODULE__, [])
        |> Keyword.get(key, default)
      end
    end

    repo_func_asts = Enum.map(@read_funcs ++ @write_funcs, fn {func_name, func_arity} ->
      func_args = case func_arity do
        0 -> []
        arity -> Enum.map(1..arity, &(Macro.var (:"arg#{&1}"), __CALLER__.module))
      end

      quote do
        def unquote(func_name)(unquote_splicing(func_args)) do
          call(unquote(func_name), [unquote_splicing(func_args)])
        end
      end
    end)

    [proxy_ast] ++ repo_func_asts
  end
end
