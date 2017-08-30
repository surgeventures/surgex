defmodule Surgex.Parseus.CastProcessor do
  alias Surgex.Parseus

  def call(self = %Parseus{input: input, result: result, mapping: mapping}, fields) do
    {new_result, new_mapping} = Enum.reduce(fields, {result, mapping}, fn field, {result, mapping} ->
      field_key = make_key(field)
      new_mapping = Keyword.put(mapping, field_key, field)

      case Access.fetch(input, field) do
        {:ok, value} ->
          new_result = Keyword.put(result, field_key, value)
          {new_result, new_mapping}
        :error ->
          {result, new_mapping}
      end
    end)

    %{self | result: new_result, mapping: new_mapping}
  end

  defp make_key(input) when is_atom(input), do: input
  defp make_key(input) when is_binary(input) do
    input
    |> Macro.underscore
    |> String.replace("-", "_")
    |> String.to_atom
  end
end
