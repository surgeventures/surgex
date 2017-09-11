defmodule Surgex.Parseus.CastProcessor do
  @moduledoc false

  @nil_value Surgex.Parseus.CastProcessor.NotFound

  alias Surgex.Parseus.Set

  def call(set, input_key) when not(is_list(input_key)) do
    call(set, [input_key])
  end
  def call(set = %Set{input: input, output: output, mapping: mapping}, input_keys) do
    {new_output, new_mapping} = reduce_input_keys(input_keys, input, output, mapping)

    %{set | output: new_output, mapping: new_mapping}
  end
  def call(input, input_keys) do
    call(%Set{input: input}, input_keys)
  end

  defp reduce_input_keys(input_keys, input, output, mapping) do
    Enum.reduce(input_keys, {output, mapping}, fn input_key, {output, mapping} ->
      output_key = make_key(input_key)
      new_mapping = Keyword.put(mapping, output_key, input_key)

      case fetch(input, input_key) do
        {:ok, value} ->
          new_output = Keyword.put(output, output_key, value)
          {new_output, new_mapping}
        :error ->
          {output, new_mapping}
      end
    end)
  end

  defp fetch(input, {:key, input_key}) do
    case get_in(input, [Access.key(input_key, @nil_value)]) do
      @nil_value -> :error
      value -> {:ok, value}
    end
  end
  defp fetch(input, input_key), do: Access.fetch(input, input_key)

  defp make_key({:key, input}) when is_atom(input), do: input
  defp make_key(input) when is_atom(input), do: input
  defp make_key(input) when is_binary(input) do
    input
    |> Macro.underscore
    |> String.replace("-", "_")
    |> String.to_atom
  end
end
