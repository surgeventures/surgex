defmodule Surgex.DeviseSession do
  @moduledoc """
  `Plug.Session` patched for `Surgex.Config` capabilities.

  Surgex version of this plug invokes `Surgex.Config.parse/1` on the `:domain` option,
  allowing to fetch the session cookie domain from system env on runtime.

  Refer to `Plug.Session` docs for info about the actual plug and its API.
  """

  alias Plug.Session
  alias Surgex.Config
  alias Surgex.DeviseSession.Marshal

  @default_opts [
    store: PlugRailsCookieSessionStore,
    serializer: Marshal,
    encryption_salt: "encrypted cookie",
    signing_salt: "signed encrypted cookie",
    key_iterations: 1000,
    key_length: 64,
    key_digest: :sha,
  ]

  def init(opts) do
    @default_opts
    |> Keyword.merge(opts)
    |> Session.init()
  end

  def call(conn, config) do
    Session.call(conn, patch_config(config))
  end

  defp patch_config(config) do
    config
    |> update_in(config.cookie_opts[:domain], &Config.parse/1)
    |> update_in(config.store_config[:encryption_salt], &Config.parse/1)
    |> update_in(config.store_config[:signing_salt], &Config.parse/1)
  end
end
