defmodule Surgex.Scout do
  @moduledoc """
  Extensions to the official Scout package.
  """

  alias Surgex.Config

  @doc """
  Patches Scout environment key from env vars.

  By default, ScoutApm package does not allow to fetch key from env var.

  ## Examples

  In order to execute this extension on application start, set an appropriate config key:

      config :surgex,
        scout_patch_enabled: true

  """
  def init do
    if Application.get_env(:surgex, :scout_patch_enabled, false), do: do_init()
  end

  defp do_init do
    require Logger

    api_key = get_api_key()

    Logger.info fn ->
      "Patching Scout config (api_key: #{inspect api_key})"
    end

    Mix.Config.persist(scout_apm: [key: api_key])
  end

  defp get_api_key do
    case Application.get_env(:surgex, :scout_api_key, "") do
      value ->
        Config.parse(value)
    end
  end
end
