defmodule Surgex.DataPipe do
  @moduledoc """
  Tools for moving data between PostgreSQL databases and tables.

  The following tools are available:

  - `Surgex.DataPipe.FollowerSync`: waits for a slave synchronization with a remote master
  - `Surgex.DataPipe.ForeignDataWrapper`: configures a FDW linkage between two repos
  - `Surgex.DataPipe.TableSync`: ETLs data from one database or table into another

  ## Usage

  A common scenario may be to wait for a message or event coming from an external service that has
  just made a change in an OLTP master database (D1) which we can access via a read-only slave (D2)
  for puproses of efficient ETL into our own OLAP database (D3). Let's see what steps and what tools
  from this module are involved in such a data pipe.

  First, since we're using slave that replicates data from master with a delay, we may want to wait
  for it to catch up with a master to a point at which the event was triggered. In order to do that,
  the external service should include the current log location (lsn) of D1 in the event. We can use
  that to wait for D2 to catch up:

      %{lsn: lsn} = external_event
      FollowerSync.call(D2Repo, lsn)

  Then, we may connect our D3 database to D2 via an efficient PostgreSQL FDW link in order for data
  to flow directly between databases without having to load them into app memory:

      ForeignDataWrapper.call(D3Repo, D2Repo)

  Finally, we may synchronize data between two repos using a native Ecto syntax:

      query =
        D2Sale
        |> where(...)
        |> select(...)
        |> ForeignDataWrapper.prefix(D2Repo)

      TableSync.call(D3Repo, query, D3FactSale)

  That's it. You now have an up-to-date copy of reduced data from OLTP master in your OLAP database.
  """
end
