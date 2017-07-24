defmodule Surgex.DataPipe.FollowerSync do
  @moduledoc """
  Waits for a PostgreSQL slave synchronization with a remote master.

  Refer to `Surgex.DataPipe` for usage examples.
  """

  require Logger
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
    if enabled?() do
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

    cond do
      normalize_lsn(last_lsn) >= normalize_lsn(lsn) ->
        Logger.info(fn -> "Follower sync acquired after #{elapsed_time}ms" end)
        :ok

      elapsed_time >= timeout() ->
        Logger.error(fn -> "Follower sync timeout after #{timeout()}ms: #{last_lsn} < #{lsn}" end)
        {:error, :timeout}

      true ->
        :timer.sleep(interval())
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

  defp enabled?, do: Application.get_env(:surgex, :follower_sync_enabled, true)

  defp timeout, do: Application.get_env(:surgex, :follower_sync_timeout, 15_000)

  defp interval, do: Application.get_env(:surgex, :follower_sync_interval, 1_000)
end
