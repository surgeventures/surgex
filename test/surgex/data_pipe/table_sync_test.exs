defmodule Surgex.DataPipe.TableSyncTest do
  use Surgex.DataCase
  import Surgex.Factory
  alias Surgex.DataPipe.TableSync
  alias Surgex.User

  test "sync to empty table" do
    insert_list(2, :user)

    columns = ~w{id provider_id name}a
    query = select(User, ^columns)
    opts = [
      on_conflict: :replace_all,
      conflict_target: [:id],
      scope: [provider_id: 1],
      params: []]

    {upserts, deletions} = TableSync.call(Repo, "other_users", columns, query, opts)

    assert upserts == 2
    assert deletions == 0
  end
end
