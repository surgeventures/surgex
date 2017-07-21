defmodule Surgex.RefactorTest do
  use ExUnit.Case
  import ExUnit.CaptureIO
  alias Surgex.Refactor

  setup do
    File.rm_rf!("test/samples")
    File.mkdir_p!("test/samples")

    File.write(
      "test/samples/valid_xyz_mod.ex",
      "defmodule Surgex.Refactor.MapFilenamesTest.ValidXYZMod, do: nil")

    File.write(
      "test/samples/wrong_xyz_mod.ex",
      "defmodule Surgex.Refactor.MapFilenamesTest.InvalidXYZMod, do: nil")
  end

  test "expands recursively when no path is given" do
    result = capture_io(fn ->
      Refactor.call([
        "map_filenames",
      ])
    end)

    assert result =~ ~r(wrong_xyz_mod.ex)

    File.rm_rf!("test/samples")
  end

  test "handles wrong path" do
    result = capture_io(fn ->
      Refactor.call([
        "map_filenames",
        "wrong_path",
      ])
    end)

    assert result =~ ~r/No files found/

    File.rm_rf!("test/samples")
  end


  test "map filenames without fixing them" do
    result = capture_io(fn ->
      Refactor.call([
        "map_filenames",
        "test/samples",
      ])
    end)

    assert result =~ ~r/You're in a simulation mode, pass the --fix option to apply the action./
    assert result =~ ~r(/wrong_xyz_mod.ex => test/.*/invalid_xyz_mod.ex)
    refute result =~ ~r(/valid_xyz_mod.ex)
    refute result =~ ~r/Renamed \d+ file\(s\)/
    assert File.exists?("test/samples/wrong_xyz_mod.ex")
    refute File.exists?("test/samples/invalid_xyz_mod.ex")

    File.rm_rf!("test/samples")
  end

  test "map filenames with fixing them" do
    result = capture_io(fn ->
      Refactor.call([
        "map_filenames",
        "test/samples",
        "--fix",
      ])
    end)

    refute result =~ ~r/You're in a simulation mode, pass the --fix option to apply the action./
    assert result =~ ~r(/wrong_xyz_mod.ex => test/.*/invalid_xyz_mod.ex)
    refute result =~ ~r(/valid_xyz_mod.ex)
    assert result =~ ~r/Renamed 1 file\(s\)/
    refute File.exists?("test/samples/wrong_xyz_mod.ex")
    assert File.exists?("test/samples/invalid_xyz_mod.ex")

    File.rm_rf!("test/samples")
  end
end
