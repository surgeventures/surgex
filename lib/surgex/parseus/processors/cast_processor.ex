defmodule Surgex.Parseus.CastProcessor do
  @moduledoc false

  alias Surgex.Parseus

  def call(px = %Parseus{input: input, output: output, mapping: mapping}, fields) do
    {new_output, new_mapping} = Enum.reduce(fields, {output, mapping}, fn field, {output, mapping} ->
      field_key = make_key(field)
      new_mapping = Keyword.put(mapping, field_key, field)

      case Access.fetch(input, field) do
        {:ok, value} ->
          new_output = Keyword.put(output, field_key, value)
          {new_output, new_mapping}
        :error ->
          {output, new_mapping}
      end
    end)

    %{px | output: new_output, mapping: new_mapping}
  end
  def call(input, fields) do
    call(%Parseus{input: input}, fields)
  end

  defp make_key(input) when is_atom(input), do: input
  defp make_key(input) when is_binary(input) do
    input
    |> Macro.underscore
    |> String.replace("-", "_")
    |> String.to_atom
  end
end
