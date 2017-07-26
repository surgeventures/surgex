use Mix.Config

if Mix.env == :test do
  config :logger, level: :info

  config :surgex,
    ecto_repos: [Surgex.Repo, Surgex.ForeignRepo]

  config :surgex, :config_test,
    filled_key: "filled value",
    system_key_without_default: {:system, "NON_EXISTING_ENV_VAR"},
    system_key_with_default: {:system, "NON_EXISTING_ENV_VAR", default: "default value"},
    system_key_with_boolean_type: {:system, "BOOLEAN_ENV_VAR", type: :boolean},
    system_key_with_integer_type: {:system, "INTEGER_ENV_VAR", type: :integer}

  config :surgex,
    flat_config_key: "flat value"

  config :surgex,
    follower_sync_enabled: true,
    follower_sync_timeout: 100,
    follower_sync_interval: 10

  config :surgex, Surgex.DataPipe.FollowerSyncTest.RepoWithLocalConfigMock,
    follower_sync_enabled: {:system, "BOOLEAN_ENV_VAR", type: :boolean, default: false}

  config :surgex, Surgex.Repo,
    adapter: Ecto.Adapters.Postgres,
    database: "surgex_repo_test",
    hostname: "localhost",
    pool: Ecto.Adapters.SQL.Sandbox,
    port: System.get_env("POSTGRES_TEST_PORT")

  config :surgex, Surgex.ForeignRepo,
    adapter: Ecto.Adapters.Postgres,
    database: "surgex_foreign_repo_test",
    hostname: "localhost",
    pool: Ecto.Adapters.SQL.Sandbox,
    port: System.get_env("POSTGRES_TEST_PORT")
end
