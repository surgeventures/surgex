defmodule Surgex.ScoutTest do
  use ExUnit.Case
  import ExUnit.CaptureLog
  alias Mix.Config
  alias Surgex.Scout

  describe "init/0" do
    test "patch enabled" do
      System.put_env("SCOUT_API_KEY", "test_key")

      Config.persist(
        surgex: [
          scout_patch_enabled: true,
          scout_api_key: {:system, "SCOUT_API_KEY"}
        ]
      )

      log =
        capture_log(fn ->
          Scout.init()
        end)

      assert log =~ ~s{Patching Scout config (api_key: "test_key")}
    end
  end
end
