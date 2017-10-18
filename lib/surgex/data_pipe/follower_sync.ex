defmodule Surgex.DataPipe.FollowerSync do
  @moduledoc """
  Acquires a PostgreSQL slave synchronization with a remote master.

  ## Usage

  It can be configured globally or per repo as follows:

      config :surgex,
        follower_sync_enabled: true,
        follower_sync_timeout: 15_000,
        follower_sync_interval: 1_000

      config :my_project, MyProject.MyRepo,
        # ...
        follower_sync_enabled: true,
        follower_sync_timeout: 15_000,
        follower_sync_interval: 1_000

  As a convenience versus calling `Surgex.DataPipe.FollowerSync.call/2` all the time, it can be
  `use`d in a repo module as follows:

      defmodule MyProject.MyRepo do
        use Surgex.DataPipe.FollowerSync
      end

      MyProject.MyRepo.ensure_follower_sync(lsn)

  Refer to `Surgex.DataPipe` for a complete data pipe example.
  """

  require Logger
  alias Surgex.Config
  alias Surgex.DataPipe.FollowerSync

  defmacro __using__(_) do
    quote do
      @doc """
      Waits for slave repo to catch up with master's changes up to specified log location (lsn).
      """
      def ensure_follower_sync(lsn) do
        FollowerSync.call(__MODULE__, lsn)
      end
    end
  end

  @doc """
  Waits for a given slave repo's sync up to specific remote master's lsn.
  """
  def call(repo, lsn) do
    cond do
      !enabled?(repo) ->
        :ok
      !lsn_valid?(lsn) ->
        Logger.warn("Invalid LSN: #{inspect lsn}")
        {:error, :invalid_lsn}
      true ->
        wait_for_sync(repo, lsn)
    end
  end

  defp wait_for_sync(repo, lsn, start_time \\ get_current_time()) do
    with {:ok, last_lsn} <- select_last_replay_lsn(repo) do
      handle_lsn_update(repo, lsn, last_lsn, start_time)
    end
  end

  defp handle_lsn_update(repo, lsn, last_lsn, start_time) do
    current_time = get_current_time()
    elapsed_time = current_time - start_time
    timeout = get_timeout(repo)
    interval = get_interval(repo)

    cond do
      normalize_lsn(last_lsn) >= normalize_lsn(lsn) ->
        Logger.info(fn -> "Follower sync acquired after #{elapsed_time}ms" end)
        :ok

      elapsed_time >= timeout ->
        Logger.warn(fn -> "Follower sync timeout after #{timeout}ms: #{last_lsn} < #{lsn}" end)
        {:error, :timeout}

      true ->
        :timer.sleep(interval)
        wait_for_sync(repo, lsn, start_time)
    end
  end

  defp select_last_replay_lsn(repo) do
    case apply(repo, :query!, ["SELECT pg_last_xlog_replay_location()::varchar"]) do
      %{rows: [[lsn]]} when is_binary(lsn) ->
        if lsn_valid?(lsn) do
          {:ok, lsn}
        else
          Logger.warn(fn -> "Invalid replay LSN: #{inspect lsn}" end)
          {:error, :invalid_replay_lsn}
        end
      _ ->
        Logger.warn(fn -> "No replay LSN (consider setting follower_sync_enabled: false)" end)
        {:error, :no_replay_lsn}
    end
  end

  defp normalize_lsn(lsn), do: String.pad_leading(lsn, 16, "0")

  defp get_current_time, do: :os.system_time(:milli_seconds)

  defp enabled?(repo), do: get_config(repo, :follower_sync_enabled, true)

  defp get_timeout(repo), do: get_config(repo, :follower_sync_timeout, 15_000)

  defp get_interval(repo), do: get_config(repo, :follower_sync_interval, 1_000)

  defp get_config(repo, key, default) do
    case Config.get(repo, key) do
      nil ->
        Application.get_env(:surgex, key, default)
      repo_value ->
        repo_value
    end
  end

  @lsn_regex ~r/^[0-9A-F]{1,8}\/[0-9A-F]{1,8}$/

  def lsn_valid?(lsn) do
    case is_binary(lsn) && Regex.run(@lsn_regex, lsn) do
      [_] -> true
      _ -> false
    end
  end
end
