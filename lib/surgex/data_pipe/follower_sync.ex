defmodule Surgex.DataPipe.FollowerSync do
  @moduledoc """
  Waits for a PostgreSQL slave synchronization with a remote master.

  ## Usage

  Can be configured globally or per repo as follows:

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

  def call(repo, lsn) do
    if enabled?(repo) do
      wait_for_sync(repo, lsn)
    else
      :ok
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
        Logger.error(fn -> "Follower sync timeout after #{timeout}ms: #{last_lsn} < #{lsn}" end)
        {:error, :timeout}

      true ->
        :timer.sleep(interval)
        wait_for_sync(repo, lsn, start_time)
    end
  end

  defp select_last_replay_lsn(repo) do
    case apply(repo, :query!, ["SELECT pg_last_xlog_replay_location()::varchar"]) do
      %{rows: [[lsn]]} when is_binary(lsn) ->
        {:ok, lsn}
      _ ->
        Logger.error(fn -> "Unable to fetch pg_last_xlog_replay_location" end)
        {:error, :no_replay_location}
    end
  end

  defp normalize_lsn(lsn), do: String.pad_leading(lsn, 16, "0")

  defp get_current_time, do: :os.system_time(:milli_seconds)

  defp enabled?(repo), do: get_config(repo, :follower_sync_enabled, true)

  defp get_timeout(repo), do: get_config(repo, :follower_sync_timeout, 15_000)

  defp get_interval(repo), do: get_config(repo, :follower_sync_interval, 1_000)

  defp get_config(repo, key, default) do
    with repo_config when not(is_nil(repo_config)) <- Config.get(repo),
         {:ok, repo_value} <- Keyword.fetch(repo_config, key)
    do
      repo_value
    else
      _ -> Application.get_env(:surgex, key, default)
    end
  end
end
