defmodule Surgex.RepoHelpersTest do
  use ExUnit.Case

  alias Surgex.RepoHelpers
  alias Surgex.Config.Patch

  test "set db_pool_size with endpoints enabled" do
    System.put_env("TEST_DB_CONNECTION_POOL", "5")

    schema = [
      phoenix: [serve_endpoints: true]
    ]

    Patch.apply(schema)

    assert Application.get_env(:phoenix, :serve_endpoints) == true

    opts = [{:pool_size, nil}]
    response = RepoHelpers.set_db_pool_size(opts, "TEST_DB_CONNECTION_POOL")
    assert {:ok, [pool_size: 5]} == response
  end

  test 'set db_pool_size with endpoints disabled' do
    System.put_env("TEST_DB_CONNECTION_POOL", "5")

    schema = [
      phoenix: [serve_endpoints: false]
    ]

    Patch.apply(schema)

    assert Application.get_env(:phoenix, :serve_endpoints) == false

    opts = [{:pool_size, nil}]
    response = RepoHelpers.set_db_pool_size(opts, "TEST_DB_CONNECTION_POOL")
    assert {:ok, [pool_size: nil]} == response
  end

  test "set db_url" do
    System.put_env("TEST_DB_URL", "p://h:p/dbn")
    opts = [{:url, nil}]
    response = RepoHelpers.set_db_url(opts, "TEST_DB_URL")
    assert {:ok, [url: "p://h:p/dbn"]} == response
  end
end
