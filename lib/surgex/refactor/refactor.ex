defmodule Surgex.Refactor do
  @moduledoc """
  Tools for making code maintenance and refactors easier.
  """

  alias Surgex.Refactor.MapFilenames

  def call(args) do
    args
    |> parse_args
    |> call_task
  end

  defp parse_args(args) do
    parse_result = OptionParser.parse(args,
      switches: [fix: :boolean])

    {opts, task, paths} = case parse_result do
      {opts, [task | paths], _} -> {opts, task, paths}
      _ -> raise(ArgumentError, "No refactor task")
    end

    unless Keyword.get(opts, :fix, false) do
      IO.puts("You're in a simulation mode, pass the --fix option to apply the action.")
      IO.puts("")
    end

    filenames =
      paths
      |> expand_paths()
      |> filter_elixir_files()

    {task, filenames, opts}
  end

  defp call_task({task, filenames, opts}) do
    "Elixir.Surgex.Refactor.#{Macro.camelize(task)}"
    |> String.to_existing_atom()
    |> apply(:call, [filenames, opts])
  end

  defp filter_elixir_files(paths) do
    Enum.filter(paths, &String.match?(&1, ~r/\.exs?$/))
  end

  defp expand_paths([]), do: expand_paths(["."])
  defp expand_paths(paths) when is_list(paths) do
    paths
    |> Enum.map(&expand_paths/1)
    |> Enum.concat
  end
  defp expand_paths(path) do
    cond do
      File.regular?(path) -> [path]
      File.dir?(path) ->
        path
        |> File.ls!
        |> Enum.map(&Path.join(path, &1))
        |> Enum.map(&expand_paths/1)
        |> Enum.concat
      true -> []
    end
  end
end
