defmodule Surgex.Parseus.Error do
  @moduledoc """
  Represents a failure of parsing or validation.
  """

  defstruct reason: nil,
            source: nil,
            info: []

  def build(reason) when is_atom(reason) or is_binary(reason), do: build(reason: reason)
  def build({reason, info}), do: build(reason: reason, info: info)
  def build(error = %__MODULE__{}), do: error
  def build(opts) when is_list(opts) do
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
