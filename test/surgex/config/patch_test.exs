defmodule Surgex.Config.PatchTest do
  use ExUnit.Case
  import ExUnit.CaptureLog
  alias Mix.Config
  alias Surgex.Config.Patch

  describe "init/0" do
    test "patch enabled" do
      Config.persist(
        surgex: [
          config_patch: [
            some_app: [some_key: {:system, "SOME_APP_VAR"}],
            other_app: [some_key: "value"],
            another_app: [
              some_key: {:system, "ANOTHER_APP_VAR_1"},
              other_key: {:system, "ANOTHER_APP_VAR_2", default: "x"}
            ]
          ]
        ]
      )

      System.put_env("SOME_APP_VAR", "some var")
      System.put_env("ANOTHER_APP_VAR_1", "another var")

      log =
        capture_log(fn ->
          Patch.init()
        end)

      new_config = [
        some_app: [some_key: "some var"],
        other_app: [some_key: "value"],
        another_app: [some_key: "another var", other_key: "x"]
      ]

      assert log =~ ~s{Patching config: #{inspect(new_config)}}
    end
  end

  describe "apply/1" do
    test "apply patch" do
      schema = [
        some_app: [some_key: {:system, "SOME_APP_VAR"}],
        other_app: [some_key: "value"],
        another_app: [
          some_key: {:system, "ANOTHER_APP_VAR_1"},
          other_key: {:system, "ANOTHER_APP_VAR_2", default: "x"}
        ]
      ]

      System.put_env("SOME_APP_VAR", "some var")
      System.put_env("ANOTHER_APP_VAR_1", "another var")

      Patch.apply(schema)

      assert Application.get_env(:some_app, :some_key) == "some var"
      assert Application.get_env(:other_app, :some_key) == "value"
      assert Application.get_env(:another_app, :some_key) == "another var"
      assert Application.get_env(:another_app, :other_key) == "x"
    end
  end
end
