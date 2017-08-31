defmodule Surgex.Parseus.EnumParser do
  @moduledoc false

  def call(input, allowed_values) when is_binary(input) and is_list(allowed_values) do
    if input in allowed_values do
      {:ok,
        input
        |> Macro.underscore
        |> String.replace("-", "_")
        |> String.to_atom}
    else
      :error
    end
  end
end
