defmodule Surgex.Sentry do
  @moduledoc """
  Extensions to the official Sentry package.
  """

  @doc """
  Patches Sentry environment name and release version from env vars.

  By default, Sentry package only allows to fetch DSN from env var. This function extends that
  with environment name and release version set on runtime, thus enabling deployments on Heroku
  where application slug is compiled without final env vars.

  ## Examples

  In order to use this extension, invoke `Surgex.Sentry.init/0` on application start:

      defmodule MyProject.Application do
        use Application

        def start(_type, _args) do
          if Mix.env == :prod, do: Surgex.Sentry.init()

          # ...remainder of the app start code...
        end
      end

  """
  def init do
    require Logger

    env = System.get_env("SENTRY_ENVIRONMENT")
    release = System.get_env("SOURCE_VERSION") || System.get_env("HEROKU_SLUG_COMMIT")

    Logger.info fn ->
      "Patching Sentry config (environment: #{inspect(env)}, release: #{inspect(release)})"
    end

    Mix.Config.persist(sentry: [
      release: release,
      environment_name: env,
      included_environments: [env]
    ])
  end

  @scrubbed_param_keys Application.get_env(:surgex, :sentry_scrubbed_param_keys, ~w{password})
  @scrubbed_value Application.get_env(:surgex, :sentry_scrubbed_value, "[Filtered]")

  @doc """
  Deeply scrubs params, obfuscating those with blacklisted names.

  By default, Sentry package only offers flat scrubbing of params. This won't work with nested
  params or JSON objects, so here's deep recursive equivalent of such scrubber.

  ## Examples

  In order to use this extension, pass `Surgex.Sentry.scrub_params/1` to `Sentry.Plug` like this:

      use Sentry.Plug, body_scrubber: &Surgex.Sentry.scrub_params/1

  """
  def scrub_params(conn) do
    scrub_map(conn.params)
  end

  defp scrub_map(map) do
    map
    |> Enum.map(&scrub_map_item/1)
    |> Enum.into(%{})
  end

  defp scrub_list(list), do: Enum.map(list, &scrub_value/1)

  defp scrub_map_item({key, _value}) when key in @scrubbed_param_keys, do: {key, @scrubbed_value}
  defp scrub_map_item({key, value}), do: {key, scrub_value(value)}

  defp scrub_value(value) when is_map(value), do: scrub_map(value)
  defp scrub_value(value) when is_list(value), do: scrub_list(value)
  defp scrub_value(value), do: value
end
