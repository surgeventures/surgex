defmodule Surgex.Parseus.GetInputPathUtil do
  def call(mapping, output_key) when not(is_list(output_key)) do
    call(mapping, [output_key])
  end
  def call(mapping, output_path) do
    {_, path} = Enum.reduce(output_path, {mapping, []}, fn
      {key, :at, at}, {prev_mapping, prev_path} ->
        {base, :at, nested_mapping} = Keyword.fetch!(prev_mapping, key)
        {nested_mapping, to_list(prev_path) ++ to_list(base) ++ [{:at, at}]}
      key, {prev_mapping, prev_path} ->
        case Keyword.fetch!(prev_mapping, key) do
          {base, :at, nested_mapping} ->
            {nested_mapping, prev_path ++ to_list(base)}
          {base, nested_mapping} ->
            {nested_mapping, prev_path ++ to_list(base)}
          path ->
            {nil, prev_path ++ to_list(path)}
        end
    end)

    path
  end

  defp to_list(input) when is_list(input), do: input
  defp to_list(input), do: [input]
end
