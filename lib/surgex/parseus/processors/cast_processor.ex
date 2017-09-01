defmodule Surgex.Parseus.CastProcessor do
  @moduledoc false

  alias Surgex.Parseus

  def call(px = %Parseus{input: input, output: output, mapping: mapping}, input_keys) do
    {new_output, new_mapping} = Enum.reduce(input_keys, {output, mapping}, fn input_key, {output, mapping} ->
      output_key = make_key(input_key)
      new_mapping = Keyword.put(mapping, output_key, input_key)

      case Access.fetch(input, input_key) do
        {:ok, value} ->
          new_output = Keyword.put(output, output_key, value)
          {new_output, new_mapping}
        :error ->
          {output, new_mapping}
      end
    end)

    %{px | output: new_output, mapping: new_mapping}
  end
  def call(input, input_keys) do
    call(%Parseus{input: input}, input_keys)
  end

  defp make_key(input) when is_atom(input), do: input
  defp make_key(input) when is_binary(input) do
    input
    |> Macro.underscore
    |> String.replace("-", "_")
    |> String.to_atom
  end
end
