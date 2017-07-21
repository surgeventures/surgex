defmodule Surgex.DataPipe.FollowerSyncTest.RepoMock do
  def query!("SELECT pg_last_xlog_replay_location()::varchar") do
    %{rows: [["1"]]}
  end
end

defmodule Surgex.DataPipe.FollowerSyncTest.RepoWithoutLogMock do
  def query!("SELECT pg_last_xlog_replay_location()::varchar") do
    nil
  end
end

defmodule Surgex.DataPipe.FollowerSyncTest do
  use ExUnit.Case
  import ExUnit.CaptureLog
  alias Mix.Config
  alias Surgex.DataPipe.FollowerSync
  alias Surgex.DataPipe.FollowerSyncTest.{
    RepoMock,
    RepoWithoutLogMock
  }

  setup do
    :ets.new(:test_flags, [:named_table])
    :ok
  end

  test "success" do
    success = fn -> :ets.insert(:test_flags, {"success"}) end

    assert capture_log(fn ->
      assert FollowerSync.call(RepoMock, "1", success) == :ok
    end) =~ ~r/Follower sync acquired after 0ms/

    assert [{"success"}] = :ets.lookup(:test_flags, "success")
  end

  test "failure" do
    success = fn -> :ets.insert(:test_flags, {"success"}) end

    assert capture_log(fn ->
      assert FollowerSync.call(RepoMock, "2", success) == {:error, :timeout}
    end) =~ ~r/Follower sync timeout after 100ms/

    assert [] = :ets.lookup(:test_flags, "success")
  end

  test "failure with callback" do
    success = fn -> :ets.insert(:test_flags, {"success"}) end
    failure = fn -> :ets.insert(:test_flags, {"failure"}) end

    assert capture_log(fn ->
      assert FollowerSync.call(RepoMock, "2", success, failure) == {:error, :timeout}
    end) =~ ~r/Follower sync timeout after 100ms/

    assert [] = :ets.lookup(:test_flags, "success")
    assert [{"failure"}] = :ets.lookup(:test_flags, "failure")
  end

  test "repo without log" do
    success = fn -> :ets.insert(:test_flags, {"success"}) end

    assert_raise(RuntimeError, "Unable to fetch pg_last_xlog_replay_location", fn ->
      FollowerSync.call(RepoWithoutLogMock, "1", success)
    end)

    assert [] = :ets.lookup(:test_flags, "success")
  end

  test "disabled" do
    Config.persist(surgex: [
      follower_sync_enabled: false
    ])

    success = fn -> :ets.insert(:test_flags, {"success"}) end

    assert FollowerSync.call(RepoWithoutLogMock, "1", success)
    assert [{"success"}] = :ets.lookup(:test_flags, "success")

    Config.persist(surgex: [
      follower_sync_enabled: true
    ])
  end
end
