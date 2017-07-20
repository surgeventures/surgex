defmodule Surgex.Refactor.MapFilenames do
  @moduledoc """
  Maps module names to filenames and finds non-matches.
  """

  def scan(filenames) do
    filenames
    |> Enum.map(&scan_map/1)
    |> Enum.filter(&(&1))
  end

  defp scan_map(filename) do
    module_match =
      filename
      |> File.stream!()
      |> Enum.find_value(&Regex.run(~r/^defmodule ([\w.]+)/, &1))

    with [_, module_name] <- module_match do
      new_filename_wo_ext =
        module_name
        |> String.split(".")
        |> List.last()
        |> Macro.underscore()

      new_filename = Path.join(
        Path.dirname(filename),
        new_filename_wo_ext <> Path.extname(filename))

      if filename != new_filename do
        {filename, new_filename}
      end
    else
      _ -> nil
    end
  end

  def fix(scanned_tuples) do
    Enum.map(scanned_tuples, fn {filename, new_filename} ->
      File.rename(filename, new_filename)
    end)
  end
end
