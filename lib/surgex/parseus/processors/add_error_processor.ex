defmodule Surgex.Parseus.AddErrorProcessor do
  alias Surgex.Parseus.{
    Error,
    Set,
  }

  def call(set = %Set{errors: errors}, output_keys, error) do
    new_errors = put_error(errors, to_list(output_keys), Error.build(error))
    %{set | errors: new_errors}
  end

  defp to_list(input) when is_list(input), do: input
  defp to_list(input), do: [input]

  defp put_error(target, [{:at, index} | rest], error) do
    target_map =
      target
      |> Enum.map(fn {:at, index, errors} -> {index, errors} end)
      |> Map.new

    nested_target = target_map[{:at, index}] || []
    nested_errors = put_error(nested_target, rest, error)
    new_target_map = Map.put(target_map, index, nested_errors)
    new_target = Enum.map(new_target_map, fn {index, errors} -> {:at, index, errors} end)
    new_target
  end
  defp put_error(target, [key], error) do
    [{key, error} | target]
  end
  defp put_error(target, [key | rest], error) do
    nested_target = target[key] || []
    nested_errors = put_error(nested_target, rest, error)

    [{key, nested_errors} | target]
  end
end
