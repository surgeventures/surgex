defmodule Surgex.RepoHelpersTest do
  use ExUnit.Case

  alias Surgex.RepoHelpers
  doctest Surgex.RepoHelpers

  test "set_opts" do
    System.put_env("DATABASE_URL", "p://h:p/dbn")
    System.put_env("DATABASE_SERVER_POOL_SIZE", "5")
    System.put_env("DATABASE_SSL", "true")
    Application.put_env(:phoenix, :serve_endpoints, true)

    final_opts = RepoHelpers.set_opts([])

    assert final_opts[:url] == "p://h:p/dbn"
    assert final_opts[:pool_size] == 5
    assert final_opts[:ssl] == true
  end

  test "set_opts with custom prefix" do
    System.put_env("MY_REPO_URL", "p://h:p/dbn")
    System.put_env("MY_REPO_SERVER_POOL_SIZE", "5")
    System.put_env("MY_REPO_SSL", "true")

    Application.put_env(:phoenix, :serve_endpoints, true)

    final_opts = RepoHelpers.set_opts([], :my_repo)

    assert final_opts[:url] == "p://h:p/dbn"
    assert final_opts[:pool_size] == 5
    assert final_opts[:ssl] == true
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

  test "set_ssl set true" do
    System.put_env("TEST_DB_SSL", "true")
    final_opts = RepoHelpers.set_ssl([], "TEST_DB_SSL")
    assert final_opts[:ssl] == true
  end

  test "set_ssl set false" do
    System.put_env("TEST_DB_SSL", "false")
    final_opts = RepoHelpers.set_ssl([], "TEST_DB_SSL")
    assert final_opts[:ssl] == false
  end

  test "set_ssl set random value" do
    System.put_env("TEST_DB_SSL", "random")
    final_opts = RepoHelpers.set_ssl([], "TEST_DB_SSL")
    refute Keyword.has_key?(final_opts, :ssl)
  end

  test "set_ssl not set env var" do
    System.delete_env("TEST_DB_SSL")
    final_opts = RepoHelpers.set_ssl([], "TEST_DB_SSL")
    refute Keyword.has_key?(final_opts, :ssl)
  end

  test "set_application_name no env var, no existing params" do
    System.delete_env("APP_NAME")
    opts = RepoHelpers.set_application_name([])
    refute Keyword.has_key?(opts, :parameters)
  end

  test "set_application_name no env var, existing params" do
    System.delete_env("APP_NAME")

    opts =
      RepoHelpers.set_application_name(
        parameters: [test_key: "test_value", application_name: "surgex"]
      )

    assert opts[:parameters][:test_key] == "test_value"
    assert opts[:parameters][:application_name] == "surgex"
  end

  test "set_application_name env var present, no existing params" do
    System.put_env("APP_NAME", "app-name-from-env")
    opts = RepoHelpers.set_application_name([])
    assert opts[:parameters][:application_name] == "app-name-from-env"
  after
    System.delete_env("APP_NAME")
  end

  test "set_application_name env var present, existing params" do
    System.put_env("APP_NAME", "app-name-from-env")

    opts =
      RepoHelpers.set_application_name(
        parameters: [test_key: "test_value", application_name: "surgex"]
      )

    assert opts[:parameters][:test_key] == "test_value"
    assert opts[:parameters][:application_name] == "app-name-from-env"
  after
    System.delete_env("APP_NAME")
  end

  test "set_application_name trims names longet than 63" do
    System.put_env(
      "APP_NAME",
      "this-is-very-very-very-very-very-very-very-very-long-app-name->|<-chop here"
    )

    opts = RepoHelpers.set_application_name([])

    assert opts[:parameters][:application_name] ==
             "this-is-very-very-very-very-very-very-very-very-long-app-name->"
  after
    System.delete_env("APP_NAME")
  end
end
