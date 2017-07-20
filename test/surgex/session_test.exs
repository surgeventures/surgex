defmodule Surgex.SessionTest do
  use ExUnit.Case
  use Plug.Test
  alias Surgex.Config.Session
  alias Plug.Conn

  test "patches the config" do
    System.put_env("SESSION_COOKIE_DOMAIN", "my.domain.com")

    secret_key_base =
      1..64
      |> Enum.map(fn _ -> "x" end)
      |> Enum.join()

    conn = conn(:get, "/foo")
    opts = [store: :ets,
            key: "_sample_key",
            table: :session,
            signing_salt: "KCQNzkSI",
            domain: {:system, "SESSION_COOKIE_DOMAIN"}]

    :ets.new(:session, [:named_table, :public, read_concurrency: true])

    final_conn =
      conn
      |> Map.put(:secret_key_base, secret_key_base)
      |> Session.call(Session.init(opts))
      |> Conn.fetch_session()
      |> Conn.put_session("key", "value")
      |> resp(200, "")
      |> send_resp()

    assert [{"set-cookie", _} | _] = final_conn.resp_headers
  end
end
