defmodule Surgex.DataPipe.CleanerTest do
  use Surgex.DataCase
  import Surgex.Factory
  alias Surgex.DataPipe.Cleaner
  alias Surgex.{
    OtherUser,
    User,
  }

  setup do
    Cleaner.call(Repo)

    insert(:user)
    insert(:other_user)

    :ok
  end

  @tag transaction: false
  test "default" do
    Cleaner.call(Repo)

    assert Repo.aggregate(User, :count, :id) == 0
    assert Repo.aggregate(OtherUser, :count, :id) == 0

    assert insert(:user).id == 1
  end

  @tag transaction: false
  test "method = delete_all" do
    Cleaner.call(Repo, method: :delete_all)

    assert Repo.aggregate(User, :count, :id) == 0
    assert Repo.aggregate(OtherUser, :count, :id) == 0

    assert insert(:user).id != 1
  end

  @tag transaction: false
  test "tables = [string]" do
    Cleaner.call(Repo, only: ["users"])

    assert Repo.aggregate(User, :count, :id) == 0
    assert Repo.aggregate(OtherUser, :count, :id) == 1
  end

  @tag transaction: false
  test "tables = [schema]" do
    Cleaner.call(Repo, only: [User])

    assert Repo.aggregate(User, :count, :id) == 0
    assert Repo.aggregate(OtherUser, :count, :id) == 1
  end
end
