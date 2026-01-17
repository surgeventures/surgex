defmodule Surgex.DataPipe do
  @moduledoc """
  Tools for PostgreSQL replication and system utilities.

  The following tools are available:

  - `Surgex.DataPipe.FollowerSync`: waits for a replica synchronization with a remote primary
  - `Surgex.DataPipe.PostgresSystemUtils`: PostgreSQL system-level queries (version, WAL LSN, etc.)

  ## Usage

  A common scenario is to wait for a message or event coming from an external service that has
  just made a change in a primary database (D1) which we can access via a read-only replica (D2).
  Since replication has delay, we may want to wait for the replica to catch up.

  The external service should include the current log location (LSN) of D1 in the event:

      %{lsn: d1_lsn} = external_event
      FollowerSync.call(D2Repo, d1_lsn)

  This ensures your replica has caught up to the point where the change was made.
  """
end
