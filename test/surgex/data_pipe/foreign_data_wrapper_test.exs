defmodule Surgex.DataPipe.ForeignDataWrapperTest do
  use Surgex.DataCase
  import ExUnit.CaptureLog
  alias Surgex.DataPipe.ForeignDataWrapper
  alias Surgex.{
    ForeignFactory,
    ForeignUser,
  }

  @tag transaction: false
  test "successfully connects to foreign repo" do
    assert capture_log(fn ->
      ForeignDataWrapper.init(Repo, ForeignRepo)
    end) =~ ~r/Preparing foreign data wrapper at Repo.foreign_repo/

    ForeignFactory.insert(:foreign_user)

    assert (
      ForeignUser
      |> ForeignDataWrapper.prefix(ForeignRepo)
      |> Repo.aggregate(:count, :id)
    ) == 1
  end
end
