use Mix.Config

config :surgex, :config_test,
  filled_key: "filled value",
  system_key_without_default: {:system, "NON_EXISTING_ENV_VAR"},
  system_key_with_default: {:system, "NON_EXISTING_ENV_VAR", default: "default value"},
  system_key_with_boolean_type: {:system, "BOOLEAN_ENV_VAR", type: :boolean},
  system_key_with_integer_type: {:system, "INTEGER_ENV_VAR", type: :integer}

config :surgex, flat_config_key: "flat value"
