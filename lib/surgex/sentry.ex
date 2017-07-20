defmodule Surgex.Sentry do
  @moduledoc """
  Extensions to the official Sentry package.
  """

  alias Mix.Project
  alias Surgex.Config

  @doc """
  Patches Sentry environment name and release version from env vars.

  By default, Sentry package only allows to fetch DSN from env var. This function extends that
  with environment name and release version set on runtime, thus enabling deployments on Heroku
  where application slug is compiled without final env vars.

  ## Examples

  In order to execute this extension on application start, set an appropriate config key:

      config :surgex,
        sentry_patch_enabled: true

  """
  def init do
    if Application.get_env(:surgex, :sentry_patch_enabled, false), do: do_init()
  end

  defp do_init do
    require Logger

    env = get_env()
    release = get_release()

    Logger.info fn ->
      "Patching Sentry config (environment: #{inspect env}, release: #{inspect release})"
    end

    Mix.Config.persist(sentry: [
      release: release,
      environment_name: env,
      included_environments: [env]
    ])
  end

  defp get_env do
    case Application.get_env(:surgex, :sentry_environment, :mix_env) do
      :mix_env ->
        Mix.env()
      value ->
        Surgex.Config.parse(value)
    end
  end

  defp get_release do
    case Application.get_env(:surgex, :sentry_release, :mix_version) do
      :mix_version ->
        Project.config[:version]
      value ->
        Config.parse(value)
    end
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
  def scrub_params(%Plug.Conn{params: params}), do: scrub_map(params)

  defp scrub_map(map = %{}) do
    map
    |> Enum.map(&scrub_map_item/1)
    |> Map.new()
  end

  defp scrub_list(list), do: Enum.map(list, &scrub_value/1)

  defp scrub_map_item({key, _value}) when key in @scrubbed_param_keys, do: {key, @scrubbed_value}
  defp scrub_map_item({key, value}), do: {key, scrub_value(value)}

  defp scrub_value(value) when is_map(value), do: scrub_map(value)
  defp scrub_value(value) when is_list(value), do: scrub_list(value)
  defp scrub_value(value), do: value
end
