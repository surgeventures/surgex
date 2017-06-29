use Mix.Config

config :surgex, :config_test,
  filled_key: "filled value",
  system_key_without_default: {:system, "NON_EXISTING_ENV_VAR"},
  system_key_with_default: {:system, "NON_EXISTING_ENV_VAR", "default value"}

config :surgex, flat_config_key: "flat value"

