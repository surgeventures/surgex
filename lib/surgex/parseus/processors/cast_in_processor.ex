defmodule Surgex.Parseus.CastInProcessor do
  @moduledoc false

  alias Surgex.Parseus.{
    CallUtil,
    Set,
  }

  def call(set, input_key, output_key, proc) when not(is_list(input_key)) do
    call(set, [input_key], output_key, proc)
  end
  def call(set = %Set{input: input}, input_keys, nil, proc) do
    value = get_in(input, input_keys) || %{}
    new_px = CallUtil.call(proc, value)
    new_output = new_px.output ++ set.output
    new_errors = new_px.errors ++ set.errors
    new_mapping = nest_mapping(new_px.mapping, input_keys) ++ set.mapping

    %{set | output: new_output, errors: new_errors, mapping: new_mapping}
  end
  def call(set = %Set{input: input}, input_keys, output_key, proc) do
    with value when not(is_nil(value)) <- get_in(input, input_keys) do
      new_px = CallUtil.call(proc, value)
      new_output = [{output_key, new_px.output} | set.output]
      new_errors = case new_px.errors do
        [] -> set.errors
        _ -> [{output_key, new_px.errors} | set.errors]
      end

      new_mapping = [{output_key, {input_keys, new_px.mapping}} | set.mapping]

      %{set | output: new_output, errors: new_errors, mapping: new_mapping}
    else
      _ ->
        new_mapping = [{output_key, {input_keys, nil}} | set.mapping]

         %{set | mapping: new_mapping}
    end
  end
  def call(input, input_keys, output_key, proc) do
    call(%Set{input: input}, input_keys, output_key, proc)
  end

  defp nest_mapping(nested_mapping, input_keys) do
    Enum.map(nested_mapping, fn
      {nested_output_key, {base, :at, deep_nested}} ->
        {nested_output_key, {input_keys ++ base, :at, deep_nested}}
      {nested_output_key, {base, deep_nested}} ->
        {nested_output_key, {input_keys ++ base, deep_nested}}
      {nested_output_key, nested_input_keys} when is_list(nested_input_keys) ->
        {nested_output_key, input_keys ++ nested_input_keys}
      {nested_output_key, nested_input_key} ->
        # credo:disable-for-next-line Credo.Check.Refactor.AppendSingleItem
        {nested_output_key, input_keys ++ [nested_input_key]}
    end)
  end
end
