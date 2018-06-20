defmodule Surgex.DataPipe.PostgresSystemUtils do
  @moduledoc """
  Executes system-level PostgreSQL queries (server version, WAL status etc).
  """

  def full_version_string(repo) do
    %{rows: [[value]]} = repo.query!("SELECT version()")
    value
  end

  def version(repo) do
    full_version_string = full_version_string(repo)
    version_match = Regex.run(~r/PostgreSQL (\d+\.\d+(\.\d+)?)/, full_version_string)

    unless version_match do
      raise("Invalid full version string: #{full_version_string}")
    end

    version_match
    |> Enum.at(1)
    |> append_patch_version()
    |> Version.parse!()
  end

  defp append_patch_version(version_string) do
    if String.match?(version_string, ~r/^\d+\.\d+$/) do
      "#{version_string}.0"
    else
      version_string
    end
  end

  def version_match?(repo, requirement) do
    repo
    |> version()
    |> Version.match?(requirement)
  end

  def get_current_wal_lsn(repo) do
    get_lsn(repo, get_current_wal_lsn_function(repo))
  end

  def get_current_wal_lsn_function(repo) do
    if version_match?(repo, ">= 10.0.0") do
      "pg_current_wal_lsn()"
    else
      "pg_current_xlog_location()"
    end
  end

  def get_last_wal_replay_lsn(repo) do
    get_lsn(repo, get_last_wal_replay_lsn_function(repo))
  end

  def get_last_wal_replay_lsn_function(repo) do
    if version_match?(repo, ">= 10.0.0") do
      "pg_last_wal_replay_lsn()"
    else
      "pg_last_xlog_replay_location()"
    end
  end

  def get_lsn(repo, func) do
    with %{rows: [[lsn]]} <- repo.query!("SELECT #{func}::varchar"),
         true <- lsn_valid?(lsn) do
      {:ok, lsn}
    else
      _ -> :error
    end
  end

  def lsn_valid?(lsn) do
    is_binary(lsn) && String.match?(lsn, ~r/^[0-9A-F]+\/[0-9A-F]+$/)
  end
end
