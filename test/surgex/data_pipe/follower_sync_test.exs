defmodule Surgex.DataPipe.FollowerSyncTest.RepoMock do
  def query!("SELECT pg_last_xlog_replay_location()::varchar") do
    %{rows: [["0/00000001"]]}
  end
end

defmodule Surgex.DataPipe.FollowerSyncTest.RepoWithUsingMock do
  use Surgex.DataPipe.FollowerSync

  def query!("SELECT pg_last_xlog_replay_location()::varchar") do
    %{rows: [["0/00000001"]]}
  end
end

defmodule Surgex.DataPipe.FollowerSyncTest.RepoWithoutLogMock do
  def query!("SELECT pg_last_xlog_replay_location()::varchar") do
    nil
  end
end

defmodule Surgex.DataPipe.FollowerSyncTest.RepoWithLocalConfigMock do
  def query!("SELECT pg_last_xlog_replay_location()::varchar") do
    raise("This should never raise due to local config")
  end
end

defmodule Surgex.DataPipe.FollowerSyncTest do
  use ExUnit.Case
  import ExUnit.CaptureLog
  alias Mix.Config
  alias Surgex.DataPipe.FollowerSync
  alias Surgex.DataPipe.FollowerSyncTest.{
    RepoMock,
    RepoWithLocalConfigMock,
    RepoWithoutLogMock,
    RepoWithUsingMock,
  }

  test "success" do
    assert capture_log(fn ->
      assert FollowerSync.call(RepoMock, "0/00000001") == :ok
    end) =~ ~r/Follower sync acquired after \dms/
  end

  test "success via __using__" do
    assert capture_log(fn ->
      assert RepoWithUsingMock.ensure_follower_sync("0/00000001") == :ok
    end) =~ ~r/Follower sync acquired after \dms/
  end

  test "failure due to timeout" do
    assert capture_log(fn ->
      assert FollowerSync.call(RepoMock, "0/00000002") == {:error, :timeout}
    end) =~ ~r/Follower sync timeout after 100ms/
  end

  test "failure due to invalid lsn" do
    assert capture_log(fn ->
      assert FollowerSync.call(RepoMock, "asd") == {:error, :invalid_lsn}
    end) =~ ~r/Invalid LSN/

    assert capture_log(fn ->
      assert FollowerSync.call(RepoMock, nil) == {:error, :invalid_lsn}
    end) =~ ~r/Invalid LSN/
  end

  test "repo without log" do
    assert capture_log(fn ->
      assert FollowerSync.call(RepoWithoutLogMock, "0/00000001") == {:error, :no_replay_lsn}
    end) =~ ~r/No replay LSN/
  end

  test "repo with local config" do
    capture_log(fn ->
      assert FollowerSync.call(RepoWithLocalConfigMock, "0/00000001") == :ok
    end)
  end

  test "disabled" do
    Config.persist(surgex: [
      follower_sync_enabled: false
    ])

    assert FollowerSync.call(RepoWithoutLogMock, "0/00000001") == :ok

    Config.persist(surgex: [
      follower_sync_enabled: true
    ])
  end
end
