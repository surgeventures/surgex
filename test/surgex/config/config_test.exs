defmodule Surgex.ConfigTest do
  use ExUnit.Case
  alias Surgex.Config

  describe "get/2" do
    test "gets flat config" do
      assert Config.get(:flat_config_key) == "flat value"
    end

    test "gets nested config" do
      assert Config.get(:config_test, :filled_key) == "filled value"
      assert Config.get(:config_test, :system_key_without_default) == nil
      assert Config.get(:config_test, :system_key_with_default) == "default value"
    end
  end

  describe "parse/1" do
    test "parses flat values" do
      assert Config.parse("value") == "value"
    end

    test "parses system tuples" do
      assert Config.parse({:system, "NON_EXISTING_ENV_VAR"}) == nil
    end

    test "parses system tuples with a list of vars" do
      System.put_env("EXISTING_ENV_VAR_1", "A")
      System.put_env("EXISTING_ENV_VAR_2", "B")

      assert Config.parse({:system, ["NON_EXISTING_ENV_VAR_1", "NON_EXISTING_ENV_VAR_2"]}) == nil

      assert Config.parse(
               {:system,
                [
                  "NON_EXISTING_ENV_VAR_1",
                  "EXISTING_ENV_VAR_1",
                  "EXISTING_ENV_VAR_2"
                ]}
             ) == "A"
    end

    test "parses system tuples with a default" do
      System.put_env("EXISTING_ENV_VAR", "value")
      assert Config.parse({:system, "EXISTING_ENV_VAR", default: "default value"}) == "value"

      assert Config.parse({:system, "NON_EXISTING_ENV_VAR", default: "default value"}) ==
               "default value"
    end

    test "parses boolean system tuples" do
      System.put_env("BOOLEAN_ENV_VAR", "0")
      assert Config.parse({:system, "BOOLEAN_ENV_VAR", type: :boolean}) == false
      System.put_env("BOOLEAN_ENV_VAR", "1")
      assert Config.parse({:system, "BOOLEAN_ENV_VAR", type: :boolean}) == true
    end

    test "parses integer system tuples" do
      System.put_env("INTEGER_ENV_VAR", "0")
      assert Config.parse({:system, "INTEGER_ENV_VAR", type: :integer}) == 0
      System.put_env("INTEGER_ENV_VAR", "1")
      assert Config.parse({:system, "INTEGER_ENV_VAR", type: :integer}) == 1
      System.put_env("INTEGER_ENV_VAR", "-42")
      assert Config.parse({:system, "INTEGER_ENV_VAR", type: :integer}) == -42
    end
  end
end
