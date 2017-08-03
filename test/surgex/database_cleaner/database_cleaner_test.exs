defmodule Surgex.DatabaseCleanerTest do
  use Surgex.DataCase
  import Surgex.Factory
  alias Surgex.DatabaseCleaner
  alias Surgex.{
    OtherUser,
    User,
  }

  setup do
    insert(:user)
    insert(:other_user)

    :ok
  end

  @tag transaction: false
  test "default" do
    DatabaseCleaner.call(Repo)

    assert Repo.aggregate(User, :count, :id) == 0
    assert Repo.aggregate(OtherUser, :count, :id) == 0

    assert insert(:user).id == 1
  end

  @tag transaction: false
  test "method = delete_all" do
    DatabaseCleaner.call(Repo, method: :delete_all)

    assert Repo.aggregate(User, :count, :id) == 0
    assert Repo.aggregate(OtherUser, :count, :id) == 0

    assert insert(:user).id != 1
  end

  @tag transaction: false
  test "only = [string]" do
    DatabaseCleaner.call(Repo, only: ["users"])

    assert Repo.aggregate(User, :count, :id) == 0
    assert Repo.aggregate(OtherUser, :count, :id) == 1
  end

  @tag transaction: false
  test "only = [schema]" do
    DatabaseCleaner.call(Repo, only: [User])

    assert Repo.aggregate(User, :count, :id) == 0
    assert Repo.aggregate(OtherUser, :count, :id) == 1
  end

  @tag transaction: false
  test "except = [schema]" do
    DatabaseCleaner.call(Repo, except: [OtherUser])

    assert Repo.aggregate(User, :count, :id) == 0
    assert Repo.aggregate(OtherUser, :count, :id) == 1
  end
end
