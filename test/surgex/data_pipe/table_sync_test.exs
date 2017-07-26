defmodule Surgex.DataPipe.TableSyncTest do
  use Surgex.DataCase
  import Surgex.Factory
  alias Surgex.DataPipe.TableSync
  alias Surgex.{
    OtherUser,
    User,
  }

  setup do
    insert(:user, id: 1, email: "new@example.com")
    insert(:user, id: 2, email: "same@example.com")
    insert(:user, id: 3, email: "updated@example.com")

    insert(:user, id: 11, provider_id: 2, email: "new-s@example.com")
    insert(:user, id: 12, provider_id: 2, email: "same-s@example.com")
    insert(:user, id: 13, provider_id: 2, email: "updated-s@example.com")

    insert(:other_user, id: 2, email: "same@example.com")
    insert(:other_user, id: 3, email: "updated-x@example.com")
    insert(:other_user, id: 4, email: "deleted@example.com")

    insert(:other_user, id: 12, provider_id: 2, email: "same-s@example.com")
    insert(:other_user, id: 13, provider_id: 2, email: "updated-s-x@example.com")
    insert(:other_user, id: 14, provider_id: 2, email: "deleted-s@example.com")

    :ok
  end

  test "schema -> schema" do
    {upserts, deletions} = TableSync.call(Repo, User, OtherUser)

    assert upserts == 6
    assert deletions == 2

    assert Repo.get_by(OtherUser, email: "updated@example.com")
    assert Repo.get_by(OtherUser, email: "updated-s@example.com")
  end

  test "schema -> schema with scope" do
    {upserts, deletions} = TableSync.call(Repo, User, OtherUser, scope: [provider_id: 1])

    assert upserts == 3
    assert deletions == 1

    assert Repo.get_by(OtherUser, email: "updated@example.com")
    refute Repo.get_by(OtherUser, email: "updated-s@example.com")
  end

  test "schema -> schema with columns" do
    {upserts, deletions} = TableSync.call(Repo, User, OtherUser, columns: [:id, :provider_id])

    assert upserts == 6
    assert deletions == 2

    refute Repo.get_by(OtherUser, email: "updated@example.com")
  end

  test "query -> table" do
    columns = [:email, :id, :provider_id]
    conflict_target = [:id]
    query = from users in "users",
      where: users.id > 1,
      select: [
        fragment("upper(?)", users.email),
        users.id,
        users.provider_id,
      ]

    {upserts, deletions} = TableSync.call(Repo, query, "other_users",
      columns: columns,
      conflict_target: conflict_target)

    assert upserts == 5
    assert deletions == 2

    assert Repo.get_by(OtherUser, email: "UPDATED@EXAMPLE.COM")
  end

  test "sql -> table" do
    columns = [:email, :id, :provider_id]
    conflict_target = [:id]
    sql = "SELECT upper(email), id, provider_id FROM users WHERE id > 1"

    {upserts, deletions} = TableSync.call(Repo, sql, "other_users",
      columns: columns,
      conflict_target: conflict_target)

    assert upserts == 5
    assert deletions == 2

    assert Repo.get_by(OtherUser, email: "UPDATED@EXAMPLE.COM")
  end
end
