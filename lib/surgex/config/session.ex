defmodule Surgex.Config.Session do
  @moduledoc """
  `Plug.Session` patched for `Surgex.Config` capabilities.

  Surgex version of this plug invokes `Surgex.Config.parse/1` on the `:domain` option,
  allowing to fetch the session cookie domain from system env on runtime.

  Refer to `Plug.Session` docs for info about the actual plug and its API.
  """

  alias Plug.Session
  alias Surgex.Config

  def init(opts) do
    Session.init(opts)
  end

  def call(conn, config) do
    Session.call(conn, patch_config(config))
  end

  defp patch_config(config) do
    update_in config.cookie_opts[:domain], &Config.parse/1
  end
end
