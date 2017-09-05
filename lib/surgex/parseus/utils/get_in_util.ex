defmodule Surgex.Parseus.GetInUtil do
  def call(input, access_path) do
    get_in input, Enum.map(access_path, &map_access_key/1)
  end

  defp map_access_key({:key, key}), do: Access.key(key, nil)
  defp map_access_key(key), do: key
end
