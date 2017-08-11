defmodule Surgex.DataPipe.FollowerSyncTest.RepoMock do
  def query!("SELECT pg_last_xlog_replay_location()::varchar") do
    %{rows: [["1"]]}
  end
end

defmodule Surgex.DataPipe.FollowerSyncTest.RepoWithUsingMock do
  use Surgex.DataPipe.FollowerSync

  def query!("SELECT pg_last_xlog_replay_location()::varchar") do
    %{rows: [["1"]]}
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
      assert FollowerSync.call(RepoMock, "1") == :ok
    end) =~ ~r/Follower sync acquired after \dms/
  end

  test "success via __using__" do
    assert capture_log(fn ->
      assert RepoWithUsingMock.ensure_follower_sync("1") == :ok
    end) =~ ~r/Follower sync acquired after \dms/
  end

  test "failure" do
    assert capture_log(fn ->
      assert FollowerSync.call(RepoMock, "2") == {:error, :timeout}
    end) =~ ~r/Follower sync timeout after 100ms/
  end

  test "repo without log" do
    assert capture_log(fn ->
      FollowerSync.call(RepoWithoutLogMock, "1") == {:error, :no_replay_location}
    end) =~ ~r/Unable to fetch pg_last_xlog_replay_location/
  end

  test "repo with local config" do
    capture_log(fn ->
      FollowerSync.call(RepoWithLocalConfigMock, "1") == :ok
    end)
  end

  test "disabled" do
    Config.persist(surgex: [
      follower_sync_enabled: false
    ])

    assert FollowerSync.call(RepoWithoutLogMock, "1") == :ok

    Config.persist(surgex: [
      follower_sync_enabled: true
    ])
  end
end
