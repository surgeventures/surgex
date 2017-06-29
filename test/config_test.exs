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
      assert Config.parse({:system, "NON_EXISTING_ENV_VAR", "default value"}) == "default value"
    end
  end
end
