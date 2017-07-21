defmodule Surgex.DataPipe.ForeignDataWrapperTest do
  use Surgex.DataCase
  import ExUnit.CaptureLog
  alias Surgex.DataPipe.ForeignDataWrapper
  alias Surgex.ForeignUser

  test "init" do
    assert capture_log(fn ->
      ForeignDataWrapper.init(Repo, ForeignRepo)
    end) =~ ~r/Preparing foreign data wrapper at Repo.foreign_repo/
  end

  test "prefix" do
    assert ForeignDataWrapper.prefix(from(u in ForeignUser), ForeignRepo).prefix == "foreign_repo"
  end
end
