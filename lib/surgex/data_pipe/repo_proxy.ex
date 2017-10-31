defmodule Surgex.DataPipe.RepoProxy do
  @moduledoc """
  Proxies calls to multiple repos depending on replication needs.
  """

  defmodule Registry do
    use GenServer

    def start_link(opts) do
      name = Keyword.fetch!(opts, :name)
      GenServer.start_link(__MODULE__, [table_name: name], [name: name])
    end

    def init(opts) do
      table_name = Keyword.fetch!(opts, :table_name)
      :ets.new(table_name,
        [:set, :named_table, {:keypos, 1}, :public, {:write_concurrency, true}])

      {:ok, table_name}
    end

    def handle_cast({:monitor, pid}, state) do
      Process.monitor(pid)
      {:noreply, state}
    end

    def handle_info({:DOWN, _ref, :process, pid, _reason}, state = table_name) do
      :ets.delete(table_name, pid)
      {:noreply, state}
    end

    def register(name, pool, repo) do
      pid = self()
      GenServer.cast(name, {:monitor, pid})
      true = :ets.insert(name, {pid, pool, repo})
    end

    def lookup(name, pool) do
      case {pool, :ets.lookup(name, self())} do
        {_, []} -> nil
        {:write, [{_, :read, _}]} -> nil
        {_, [{_, _, repo}]} -> repo
      end
    end
  end

  alias Mix.Project
  alias Surgex.DataPipe.FollowerSync

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
    registry_name = :"#{__CALLER__.module}.Registry"
    proxy_ast = quote do
      use Supervisor
      require Logger

      def start_link do
        Supervisor.start_link(__MODULE__, nil, name: __MODULE__)
      end

      def init(_) do
        import Supervisor.Spec

        repos = Enum.map(get_repos(), &supervisor(&1, []))
        registry = worker(Registry, [[name: unquote(registry_name)]])
        opts = [strategy: :one_for_one]

        Supervisor.init([registry | repos], opts)
      end

      @doc """
      Calls given repo function on master or replica.

      ## Options

      - `:pool` - one of `:read`/`:write` (by default it's inferred from function name & arity)

      """
      def proxy(func, args, opts \\ []) do
        arity = length(args)
        pool = get_pool(func, arity, opts)
        process_repo = get_process_repo(pool)
        repo = process_repo || get_repo(pool)

        Registry.register(unquote(registry_name), pool, repo)
        Logger.debug(fn ->
          source = if process_repo, do: "registry", else: "#{pool} pool"
          "Proxy #{func}/#{arity} through #{inspect __MODULE__} to #{inspect repo} (from #{source})"
        end)

        apply(repo, func, args)
      end

      defp get_pool(func, arity, opts) do
        Keyword.get_lazy(opts, :pool, fn ->
          cond do
            Enum.member?(unquote(@read_funcs), {func, arity}) ->
              :read
            Enum.member?(unquote(@write_funcs), {func, arity}) ->
              :write
            true ->
              raise("Cannot determine pool for #{func}/#{arity}")
          end
        end)
      end

      @doc """
      Returns repo that was previously used by current process (if applicable for given pool).
      """
      def get_process_repo(pool \\ :read) do
        Registry.lookup(unquote(registry_name), pool)
      end

      @doc """
      Returns all proxied repos used for a given pool.
      """
      def get_repos(pool \\ :all)
      def get_repos(:all), do: get_repos(:write) ++ get_repos(:read)
      def get_repos(:read), do: get_config(:replicas, [])
      def get_repos(:write), do: [get_config!(:master)]

      @doc """
      Returns one of proxied repos for a given pool.
      """
      def get_repo(pool) do
        if test_mode?() do
          :write
          |> get_repos
          |> List.first
        else
          preferred_pool = get_repos(pool)
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
        Project.config[:app]
        |> Application.get_env(__MODULE__, [])
        |> Keyword.get(key, default)
      end

      defp get_config!(key) do
        get_config(key) || raise("#{inspect key} not set for #{inspect __MODULE__}")
      end

      def acquire_sync do
        with process_repo when not(is_nil(process_repo)) <- get_process_repo(),
             [master_repo] when master_repo != process_repo <- get_repos(:write),
             %{rows: [[lsn]]} = master_repo.query!("SELECT pg_current_xlog_location()::varchar")
        do
          FollowerSync.call(process_repo, lsn)
        else
          _ -> :ok
        end
      end
    end

    repo_func_asts = Enum.map(@read_funcs ++ @write_funcs, fn {func_name, func_arity} ->
      func_args = case func_arity do
        0 -> []
        arity -> Enum.map(1..arity, &(Macro.var (:"arg#{&1}"), __CALLER__.module))
      end

      quote do
        def unquote(func_name)(unquote_splicing(func_args)) do
          proxy(unquote(func_name), [unquote_splicing(func_args)])
        end
      end
    end)

    [proxy_ast] ++ repo_func_asts
  end
end
