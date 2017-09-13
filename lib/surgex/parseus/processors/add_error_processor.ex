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

  defp put_error(target, [{:at, index} | rest], error) when is_list(target) do
    put_error(Map.new(target), [{:at, index} | rest], error)
  end
  defp put_error(target, [{:at, index} | rest], error) when is_map(target) do
    target
    |> Map.put_new(index, [])
    |> Map.update(index, [], &put_error(&1, rest, error))
  end
  defp put_error(target, [key], error) do
    [{key, error} | target]
  end
  defp put_error(target, [key | rest], error) do
    target
    |> Keyword.put_new(key, [])
    |> Keyword.update!(key, &put_error(&1, rest, error))
  end
end



