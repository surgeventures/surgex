defmodule Surgex.RepoHelpersTest do
  use ExUnit.Case

  alias Surgex.RepoHelpers
  doctest Surgex.RepoHelpers

  test "set_opts" do
    System.put_env("DATABASE_URL", "p://h:p/dbn")
    System.put_env("DATABASE_SERVER_POOL_SIZE", "5")
    Application.put_env(:phoenix, :serve_endpoints, true)

    final_opts = RepoHelpers.set_opts([])

    assert final_opts[:url] == "p://h:p/dbn"
    assert final_opts[:pool_size] == 5
  end

  test "set_opts with custom prefix" do
    System.put_env("MY_REPO_URL", "p://h:p/dbn")
    System.put_env("MY_REPO_SERVER_POOL_SIZE", "5")

    Application.put_env(:phoenix, :serve_endpoints, true)

    final_opts = RepoHelpers.set_opts([], :my_repo)

    assert final_opts[:url] == "p://h:p/dbn"
    assert final_opts[:pool_size] == 5
  end

  test "set_url" do
    System.put_env("TEST_DB_URL", "p://h:p/dbn")
    final_opts = RepoHelpers.set_url([], "TEST_DB_URL")
    assert final_opts[:url] == "p://h:p/dbn"
  end

  test "set_server_pool_size" do
    System.put_env("TEST_DB_CONNECTION_POOL", "5")

    Application.put_env(:phoenix, :serve_endpoints, true)

    final_opts = RepoHelpers.set_server_pool_size([], "TEST_DB_CONNECTION_POOL")
    assert final_opts[:pool_size] == 5
  end

  test 'set_server_pool_size with endpoints disabled' do
    System.put_env("TEST_DB_CONNECTION_POOL", "5")

    Application.put_env(:phoenix, :serve_endpoints, false)

    final_opts = RepoHelpers.set_server_pool_size([], "TEST_DB_CONNECTION_POOL")
    assert final_opts[:pool_size] == nil
  end

  test "set_ssl true" do
    System.put_env("TEST_DB_SSL", "true")
    final_opts = RepoHelpers.set_url([], "TEST_DB_SSL")
    assert final_opts[:ssl] == true
  end

  test "set_ssl false" do
    System.put_env("TEST_DB_SSL", "false")
    final_opts = RepoHelpers.set_url([], "TEST_DB_SSL")
    assert final_opts[:ssl] == false
  end

  test "set_ssl nil" do
    System.put_env("TEST_DB_SSL", "random")
    final_opts = RepoHelpers.set_url([], "TEST_DB_SSL")
    assert final_opts[:ssl] == nil
  end
end
