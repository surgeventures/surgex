defmodule Surgex.RepoHelpers do
  @moduledoc """
  Common helpers to be used in Ecto Repos
  """

  @doc """
  Dynamically loads the repository url and connection pool size from the environment variable.
  """

  def set_db_url({:ok, opts}, db_url_env) do
    {:ok, Keyword.put(opts, :url, System.get_env(db_url_env))}
  end

  def set_db_pool_size({:ok, opts}, db_pool_size_env) do
    serve_endpoints = Application.get_env(:phoenix, :serve_endpoints)
    server_pool_size = parse_server_db_pool_size(System.get_env(db_pool_size_env))
    if serve_endpoints && is_integer(server_pool_size) do
      {:ok, Keyword.put(opts, :pool_size, server_pool_size)}
    else
      {:ok, opts}
    end
  end

  defp parse_server_db_pool_size(nil), do: nil

  defp parse_server_db_pool_size(server_pool_size_string) do
    case Integer.parse(server_pool_size_string) do
      {integer, ""} -> integer
      _ -> nil
    end
  end
end
