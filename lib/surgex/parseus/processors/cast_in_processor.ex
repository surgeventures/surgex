defmodule Surgex.Parseus.CastInProcessor do
  @moduledoc false

  alias Surgex.Parseus

  def call(px, input_key, proc, output_key) when not(is_list(input_key)) do
    call(px, [input_key], proc, output_key)
  end
  def call(px = %Parseus{input: input}, input_keys, proc, nil) do
    with value when not(is_nil(value)) <- get_in(input, input_keys) do
      new_px = apply(proc, [value])
      new_output = new_px.output ++ px.output
      new_errors = new_px.errors ++ px.errors
      new_mapping = nest_mapping(new_px.mapping, input_keys) ++ px.mapping

      %{px | output: new_output, errors: new_errors, mapping: new_mapping}
    else
      _ -> px
    end
  end
  def call(px = %Parseus{input: input}, input_keys, proc, output_key) do
    with value when not(is_nil(value)) <- get_in(input, input_keys) do
      new_px = apply(proc, [value])
      new_output = [{output_key, new_px.output} | px.output]
      new_errors = case new_px.errors do
        [] -> px.errors
        _ -> [{output_key, new_px.errors} | px.errors]
      end
      new_mapping = [{output_key, nest_mapping(new_px.mapping, input_keys)} | px.mapping]

      %{px | output: new_output, errors: new_errors, mapping: new_mapping}
    else
      _ -> px
    end
  end
  def call(input, input_keys, proc, output_key) do
    call(%Parseus{input: input}, input_keys, proc, output_key)
  end

  defp nest_mapping(nested_mapping, input_keys) do
    Enum.map(nested_mapping, fn
      {nested_output_key, nested_input_keys} when is_list(nested_input_keys) ->
        {nested_output_key, input_keys ++ nested_input_keys}
      {nested_output_key, nested_input_key} ->
        {nested_output_key, input_keys ++ [nested_input_key]}
    end)
  end
end
