defmodule Surgex.Parseus.NestedProcessor do
  @moduledoc false

  alias Surgex.Parseus

  def call(px = %Parseus{input: input, output: output, errors: errors}, key, proc) do
    with {:ok, nested_value} <- Access.fetch(input, key) do
      new_px = apply(proc, [nested_value])
      new_output = new_px.output ++ output
      new_errors = nest_errors(new_px.errors, key) ++ errors

      %{px | output: new_output, errors: new_errors}
    else
      _ -> px
    end
  end

  defp nest_errors(errors, key) do
    Enum.map(errors, fn
      {old_keys, error} when is_list(old_keys) ->
        {old_keys ++ [key], error}
      {old_key, error} ->
        {[old_key, key], error}
    end)
  end
end
