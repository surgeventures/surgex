defmodule Surgex.Parseus.CastAllInProcessor do
  @moduledoc false

  alias Surgex.Parseus.{
    CallUtil,
    GetInUtil,
    Set,
  }

  def call(set, input_key, output_key, proc) when not(is_list(input_key)) do
    call(set, [input_key], output_key, proc)
  end
  def call(set = %Set{input: input}, input_keys, output_key, proc) do
    with {:ok, values} <- fetch_all_in(input, input_keys ++ [Access.all()]) do
      {nested_output, nested_errors, nested_mapping} = reduce_nested_values(values, proc)
      new_output = [{output_key, nested_output} | set.output]
      new_errors = case nested_errors do
        empty when empty == %{} -> set.errors
        _ -> [{output_key, nested_errors} | set.errors]
      end
      new_mapping = [{output_key, {input_keys, :at, nested_mapping}} | set.mapping]

      %{set | output: new_output, errors: new_errors, mapping: new_mapping}
    else
      _ -> set
    end
  end
  def call(input, input_keys, output_key, proc) do
    call(%Set{input: input}, input_keys, output_key, proc)
  end

  defp fetch_all_in(input, input_keys) do
    {:ok, GetInUtil.call(input, input_keys)}
  rescue
    exception in RuntimeError ->
      case exception.message do
        "Access.all/0 expected a list" <> _ -> :error
        _ -> raise(exception)
      end
  end

  defp reduce_nested_values(values, proc) do
    {output, errors, mapping} =
      values
      |> Enum.with_index()
      |> Enum.reduce({[], %{}, []}, &reduce_nested_value(&1, &2, proc))

    {Enum.reverse(output), errors, mapping}
  end

  defp reduce_nested_value({value, index}, {output, errors, _}, proc) do
    new_px = CallUtil.call(proc, value)
    new_output = [new_px.output | output]
    new_errors = case new_px.errors do
      [] -> errors
      _ -> Map.put(errors, index, new_px.errors)
    end
    new_mapping = new_px.mapping

    {new_output, new_errors, new_mapping}
  end
end
