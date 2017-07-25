defmodule Surgex.DeviseSession do
  @moduledoc """
  Configures Ruby on Rails + Devise session in Plug.

  ## Usage

  Add the following to your application's endpoint (or replace an existing call to `Plug.Session`):

      plug Surgex.DeviseSession,
        key: "_my_rails_project_session"

  Here's a list of additional options:

  - `domain`: set it to `domain` provided in the `session_store()` call of your Ruby on Rails
    project

  - `serializer`: set it to `Poison` or other JSON serializer of choice if your Ruby on Rails
    project sets `cookies_serializer` to `:json` (default in Rails 4.1 and newer)

  - `signing_salt`: set it to the value of `encrypted_signed_cookie_salt` if your Ruby on Rails
     project sets it

  - `encryption_salt`: set it to the value of `encrypted_cookie_salt` if your Ruby on Rails project
    sets it

  - `signing_with_salt`: set it to `false` if your Ruby on Rails project is based on Rails 3.2 or
    older

  Remember to also set secret key base to match the one in your Rails project:

      config :my_project, MyProject.Web.Endpoint,
        secret_key_base: "secret..."

  In order to read the session, you must first fetch the session in your router pipeline:

      plug :fetch_session

  Finally, you can get the current user's identifier as follows:

      Surgex.DeviseSession.Helpers.get_user_id()

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
    |> update_in([:cookie_opts, :domain], &Config.parse/1)
    |> update_in([:store_config, :encryption_salt], &Config.parse/1)
    |> update_in([:store_config, :signing_salt], &Config.parse/1)
  end
end
