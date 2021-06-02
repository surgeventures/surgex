defmodule Surgex.Refactor.MapFilenames do
  @moduledoc """
  Maps module names to filenames and finds non-matches.
  """

  def call(filenames, opts) do
    scanned = scan(filenames)

    Enum.each(scanned, fn {filename, new_filename} ->
      IO.puts("#{filename} => #{new_filename}")
    end)

    if Enum.empty?(scanned) do
      IO.puts("No files found.")
    end

    if Keyword.get(opts, :fix, false) do
      fixed = fix(scanned)

      IO.puts("Renamed #{length(fixed)} file(s).")

      fixed
    else
      scanned
    end
  end

  def scan(filenames) do
    filenames
    |> Enum.map(&scan_map/1)
    |> Enum.filter(& &1)
  end

  defp scan_map(filename) do
    module_match =
      filename
      |> File.stream!()
      |> Enum.find_value(&Regex.run(~r/^defmodule ([\w.]+)/, &1))

    case module_match do
      [_, module_name] ->
        new_filename_wo_ext =
          module_name
          |> String.split(".")
          |> List.last()
          |> Macro.underscore()

        new_filename =
          Path.join(
            Path.dirname(filename),
            new_filename_wo_ext <> Path.extname(filename)
          )

        if filename != new_filename do
          {filename, new_filename}
        end

      _ ->
        nil
    end
  end

  def fix(scanned_tuples) do
    Enum.filter(scanned_tuples, fn {filename, new_filename} ->
      File.rename(filename, new_filename)
      true
    end)
  end
end
