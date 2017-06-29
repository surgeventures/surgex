defmodule Surgex.Config do
  @moduledoc """
  Application config getter, aka. `Application.get_env` on steroids.

  This getter embodies the usage of `{:system, "ENV_VAR_NAME"}` convention for managing configs via
  system env vars on environments like Heroku. This convention is further extended here to allow
  type casting and falling back to defaults in such tuples.

  Configs are assumed to live in app-specific parent scope, which is by default set to `:surgex`,
  but should be set to actual application name. Then, all Mix configs that will be fetched via
  `Surgex.Config` should be nested in that scope.

  Here's how your `prod.exs` may look:

      config :surgex,
        config_app_name: :my_project

      config :my_project,
        pool_size: {:system, "POOL_SIZE", :integer, 5},
        feature_x_enabled: {:system, "FEATURE_X_ENABLED", :boolean, false}

      config :my_project, :api,
        url: {:system, "API_URL"},
        enabled: {:system, "API_ENABLED", :boolean, true}

  > In other env configs, like `config.exs` and `dev.exs`, you'll usually follow the Elixir
    convention to simply fill the relevant keys with hard-coded values, optionally extracting them
    to `*.secret.exs` gitignored files to hold out-of-repo settings.

  Having that, you can use either `get/1` or `get/2` to get specific config values in all envs.
  """

  @app_name Application.get_env(:surgex, :config_app_name, :surgex)

  @doc """
  Gets the config value for specified scope and key.

  ## Examples

      iex> Mix.Config.persist(surgex: [api: [url: "example.com"]])
      [:surgex]
      iex> Surgex.Config.get(:api, :url)
      "example.com"

  """
  def get(scope, key) do
    @app_name
    |> Application.get_env(scope)
    |> Keyword.fetch(key)
    |> parse_fetch
  end
  @doc """
  Gets the config value for specified key.

  ## Examples

      iex> Mix.Config.persist(surgex: [feature_enabled: true])
      [:surgex]
      iex> Surgex.Config.get(:feature_enabled)
      true

  """
  def get(key) do
    @app_name
    |> Application.fetch_env(key)
    |> parse_fetch
  end

  @types ~w{boolean integer}a

  defp parse_fetch({:ok, {:system, env}}), do: System.get_env(env)
  defp parse_fetch({:ok, {:system, env, type}}) when type in @types do
    env
    |> System.get_env
    |> to_type(type)
  end
  defp parse_fetch({:ok, {:system, env, default}}) do
    env
    |> System.get_env
    |> or_default(default)
  end
  defp parse_fetch({:ok, {:system, env, type, default}}) when type in @types do
    env
    |> System.get_env
    |> to_type(type)
    |> or_default(default)
  end
  defp parse_fetch({:ok, value}), do: value
  defp parse_fetch(:error), do: nil

  @doc """
  Parses a config value which may or may not be a system tuple.

  ## Examples

      iex> Surgex.Config.parse("value")
      "value"
      iex> Surgex.Config.parse({:system, "NON_EXISTING_ENV_VAR"})
      nil
      iex> Surgex.Config.parse({:system, "NON_EXISTING_ENV_VAR", "default value"})
      "default value"

  """
  def parse({:system, env}), do: System.get_env(env)
  def parse({:system, env, type}) when type in @types do
    env
    |> System.get_env
    |> to_type(type)
  end
  def parse({:system, env, default}) do
    env
    |> System.get_env
    |> or_default(default)
  end
  def parse({:system, env, type, default}) when type in @types do
    env
    |> System.get_env
    |> to_type(type)
    |> or_default(default)
  end
  def parse(value), do: value

  defp to_type("1", :boolean), do: true
  defp to_type("0", :boolean), do: false
  defp to_type(_, :boolean), do: nil
  defp to_type(value, :integer) when is_binary(value) do
    case Integer.parse(value) do
      {integer, ""} -> integer
      _ -> nil
    end
  end
  defp to_type(_, :integer), do: nil

  defp or_default(nil, default), do: default
  defp or_default(value, _default), do: value
end
