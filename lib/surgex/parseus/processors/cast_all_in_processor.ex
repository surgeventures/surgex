defmodule Surgex.Parseus.CastAllInProcessor do
  @moduledoc false

  alias Surgex.Parseus

  def call(px, input_keys, proc, output_key \\ nil)
  def call(px, input_key, proc, output_key) when not(is_list(input_key)) do
    call(px, [input_key], proc, output_key)
  end
  def call(px = %Parseus{input: input}, input_keys, proc, output_key) do
    get_in_result = fetch_all_in(input, input_keys)

    with {:ok, values} <- get_in_result do
      {nested_output, nested_errors, nested_mapping} = reduce_nested_values(values, proc)
      new_output = [{output_key, nested_output} | px.output]
      new_errors = case nested_errors do
        [] -> px.errors
        _ -> [{output_key, nested_errors} | px.errors]
      end
      new_mapping = [{output_key, nest_mapping(nested_mapping, input_keys)} | px.mapping]

      %{px | output: new_output, errors: new_errors, mapping: new_mapping}
    else
      _ -> px
    end
  end
  def call(input, input_keys, proc, output_key) do
    call(%Parseus{input: input}, input_keys, proc, output_key)
  end

  defp fetch_all_in(input, input_keys) do
    try do
      {:ok, get_in(input, input_keys)}
    rescue
      exception in RuntimeError ->
        case exception.message do
          "Access.all/0 expected a list" <> _ -> :error
          _ -> raise(exception)
        end
    end
  end

  defp reduce_nested_values(values, proc) do
    values
    |> Enum.with_index()
    |> Enum.reduce({[], [], []}, &reduce_nested_value(&1, &2, proc))
  end

  defp reduce_nested_value({value, index}, {output, errors, mapping}, proc) do
    new_px = apply(proc, [value])
    new_output = output ++ [new_px.output]
    new_errors = case errors do
      [] -> errors
      _ -> [{index, new_px.errors} | errors]
    end
    new_mapping = [{index, nest_mapping(new_px.mapping, [index])} | mapping]

    {new_output, new_errors, new_mapping}
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
