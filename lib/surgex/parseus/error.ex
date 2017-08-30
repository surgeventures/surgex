defmodule Surgex.Parseus.Error do
  defstruct reason: nil,
            source: nil,
            info: []

  def build(opts) do
    struct(__MODULE__, update_in(opts[:source], &parse_source/1))
  end

  defp parse_source(input) when is_function(input), do: nil
  defp parse_source(input) when is_atom(input) do
    case to_string(input) do
      "Elixir." <> _ ->
        input
        |> Module.split
        |> List.last
        |> Macro.underscore
        |> String.to_atom
      _ ->
        input
    end
  end
end
