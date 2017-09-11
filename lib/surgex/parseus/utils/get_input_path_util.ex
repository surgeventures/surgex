defmodule Surgex.Parseus.GetInputPathUtil do
  alias Surgex.Parseus.Set

  def call(%Set{mapping: mapping}, output_path) do
    traverse_path(to_list(output_path), mapping, [])
  end

  defp traverse_path([], _mapping, result), do: result
  defp traverse_path([key, {:at, index} | rest], mapping, result) do
    {base, :at, nested_mapping} = Keyword.fetch!(mapping, key)

    traverse_path(
      rest,
      nested_mapping,
      result ++ to_list(base) ++ [{:at, index}]
    )
  end
  defp traverse_path([key | rest], mapping, result) do
    case Keyword.fetch!(mapping, key) do
      {base, :at, nested_mapping} when is_list(nested_mapping) ->
        traverse_path(
          rest,
          nested_mapping,
          result ++ to_list(base)
        )
      {base, nested_mapping} when is_list(nested_mapping) ->
        traverse_path(
          rest,
          nested_mapping,
          result ++ to_list(base)
        )
      path ->
        traverse_path(
          rest,
          nil,
          result ++ to_list(path)
        )
    end
  end

  defp to_list(input) when is_list(input), do: input
  defp to_list(input), do: [input]
end
