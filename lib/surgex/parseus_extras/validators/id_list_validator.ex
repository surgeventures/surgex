defmodule Surgex.ParseusExtras.IdListValidator do
  @moduledoc false

  def call(input) when is_list(input) do
    case Enum.find(input, &invalid_id?/1) do
      nil -> :ok
      _ -> :error
    end
  end

  defp invalid_id?(input) when is_integer(input) and input > 0, do: false
  defp invalid_id?(_input), do: true
end
