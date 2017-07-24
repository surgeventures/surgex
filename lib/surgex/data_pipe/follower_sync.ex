defmodule Surgex.DataPipe.FollowerSync do
  @moduledoc """
  Waits for a PostgreSQL slave synchronization with a remote master.

  Refer to `Surgex.DataPipe` for usage examples.
  """

  require Logger
  alias Surgex.FollowerSync

  defmacro __using__(_) do
    quote do
      @doc """
      Waits for slave repo to catch up with master's changes up to specified log location (lsn).
      """
      def ensure_follower_sync(lsn) do
        FollowerSync.call(__MODULE__, lsn, ok_func, error_func)
      end
    end
  end

  def call(repo, lsn, ok_func, error_func \\ nil) do
    if enabled?() do
      repo
      |> wait_for_replay(lsn)
      |> handle_wait_for_replay(lsn, ok_func, error_func)
    else
      ok_func.()
      :ok
    end
  end

  defp wait_for_replay(repo, lsn, start_time \\ get_current_time()) do
    last_lsn = select_last_replay_lsn(repo)
    current_time = get_current_time()
    elapsed_time = current_time - start_time

    cond do
      normalize_lsn(last_lsn) >= normalize_lsn(lsn) ->
        {:ok, elapsed_time}

      elapsed_time >= timeout() ->
        {:error, :timeout, last_lsn}

      true ->
        :timer.sleep(interval())
        wait_for_replay(repo, lsn, start_time)
    end
  end

  defp handle_wait_for_replay({:ok, elapsed_time}, _lsn, ok_func, _error_func) do
    Logger.info(fn -> "Follower sync acquired after #{elapsed_time}ms" end)

    ok_func.()

    :ok
  end
  defp handle_wait_for_replay({:error, :timeout, last_lsn}, lsn, _ok_func, error_func) do
    Logger.error(fn -> "Follower sync timeout after #{timeout()}ms: #{last_lsn} < #{lsn}" end)

    if error_func, do: error_func.()

    {:error, :timeout}
  end

  defp select_last_replay_lsn(repo) do
    case apply(repo, :query!, ["SELECT pg_last_xlog_replay_location()::varchar"]) do
      %{rows: [[lsn]]} when is_binary(lsn) ->
        lsn

      _ ->
        raise("Unable to fetch pg_last_xlog_replay_location")
    end
  end

  defp normalize_lsn(lsn), do: String.pad_leading(lsn, 16, "0")

  defp get_current_time, do: :os.system_time(:milli_seconds)

  defp enabled?, do: Application.get_env(:surgex, :follower_sync_enabled, true)

  defp timeout, do: Application.get_env(:surgex, :follower_sync_timeout, 15_000)

  defp interval, do: Application.get_env(:surgex, :follower_sync_interval, 1_000)
end
