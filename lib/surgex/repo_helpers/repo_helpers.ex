defmodule Surgex.RepoHelpers do
  @moduledoc """
  Tools for dynamic setup of Ecto repo opts.

  **NOTE: Deprecated in favor of Elixir 1.9 runtime configuration.**
  """

  @doc """
  Sets repo options from env vars starting with specified prefix.

  ## Examples

      iex> System.put_env("DATABASE_URL", "postgres://localhost")
      iex> System.put_env("DATABASE_SERVER_POOL_SIZE", "30")
      iex> System.put_env("DATABASE_SSL", "true")
      iex> Application.put_env(:phoenix, :serve_endpoints, true)
      iex>
      iex> final_opts = Surgex.RepoHelpers.set_opts([])
      iex>
      iex> Keyword.get(final_opts, :url)
      "postgres://localhost"
      iex> Keyword.get(final_opts, :pool_size)
      30
      iex> Keyword.get(final_opts, :ssl)
      true

  """
  def set_opts(opts, env_prefix \\ :database) do
    upcase_env_prefix =
      env_prefix
      |> to_string()
      |> String.upcase()

    opts
    |> set_url("#{upcase_env_prefix}_URL")
    |> set_pool_size("#{upcase_env_prefix}_POOL_SIZE")
    |> set_server_pool_size("#{upcase_env_prefix}_SERVER_POOL_SIZE")
    |> set_ssl("#{upcase_env_prefix}_SSL")
  end

  @doc """
  Sets repo database URL from specified env var.
  """
  def set_url(opts, env) do
    Keyword.put(opts, :url, System.get_env(env))
  end

  @doc """
  Sets repo database pool size from specified env var.
  """
  def set_pool_size(opts, env) do
    with env_value when is_binary(env_value) <- System.get_env(env),
         {server_pool_size, ""} <- Integer.parse(env_value) do
      Keyword.put(opts, :pool_size, server_pool_size)
    else
      _ -> opts
    end
  end

  @doc """
  Sets repo database pool size from specified env var only if Phoenix server is configured to run.
  """
  def set_server_pool_size(opts, env) do
    if Application.get_env(:phoenix, :serve_endpoints) do
      set_pool_size(opts, env)
    else
      opts
    end
  end

  @doc """
  Sets repo database ssl enable from specified env var.
  """
  def set_ssl(opts, env) do
    with env_value when is_binary(env_value) <- System.get_env(env),
         ssl_value <- String.downcase(env_value) do
      case ssl_value do
        "true" -> Keyword.put(opts, :ssl, true)
        "false" -> Keyword.put(opts, :ssl, false)
        _ -> opts
      end
    else
      _ -> opts
    end
  end
end
