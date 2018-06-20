defmodule Surgex.Config do
  @moduledoc """
  Application config getter, aka. `Application.get_env` on steroids.

  **WARNING**: This module is deprecated and will be removed in next major release. Please use
  https://github.com/surgeventures/confix instead.

  This getter embodies the usage of `{:system, "ENV_VAR_NAME"}` convention for managing configs via
  system env vars on environments like Heroku. This convention is further extended here to allow
  type casting and falling back to defaults in such tuples.

  Configs are assumed to live in app-specific parent scope, which is by default set to `:surgex`,
  but should be set to actual application name. Then, all Mix configs that will be fetched via
  `Surgex.Config` should be nested in that scope.

  Check out `Surgex.Config.Patch` for an automated solution that allows to patch any Mix config with
  the capabilities of this module.

  ## Usage

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
    |> Application.get_env(scope, [])
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

  defp parse_fetch({:ok, value}), do: parse(value)
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
  def parse({:system, env}), do: get_env(env)

  def parse({:system, env, opts}) do
    type = Keyword.get(opts, :type)
    default = Keyword.get(opts, :default)

    env
    |> get_env
    |> apply_type(type)
    |> apply_default(default)
  end

  def parse(value), do: value

  defp get_env(env) when is_binary(env), do: System.get_env(env)

  defp get_env(envs) when is_list(envs) do
    Enum.find_value(envs, &get_env/1)
  end

  defp apply_type(value, nil), do: value
  defp apply_type("1", :boolean), do: true
  defp apply_type("0", :boolean), do: false
  defp apply_type(_, :boolean), do: nil

  defp apply_type(value, :integer) when is_binary(value) do
    case Integer.parse(value) do
      {integer, ""} -> integer
      _ -> nil
    end
  end

  defp apply_type(_, :integer), do: nil

  defp apply_default(value, nil), do: value
  defp apply_default(nil, default), do: default
  defp apply_default(value, _default), do: value
end
