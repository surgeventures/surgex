defmodule Surgex.Parser do
  @moduledoc """
  Parses, casts and catches errors in the web request input, such as params or JSON API body.
  """

  use Jabbax.Document

  @doc """
  Parses controller action input (parameters, documents) with a given set of parsers.

  Returns a keyword list with parsed options.
  """
  def parse(input, parsers)
  def parse(resource = %Resource{}, parsers) do
    resource
    |> parse_resource(parsers)
    |> drop_empty_opts
  end
  def parse(doc = %Document{}, parsers) do
    doc
    |> parse_doc(parsers)
    |> drop_empty_opts
  end
  def parse(params = %{}, parsers) do
    params
    |> parse_params(parsers)
    |> drop_empty_opts
  end

  @doc """
  Parses controller action input into a flat structure.

  This function takes the same input as `parse/2` but it returns a `{:ok, value1, value2, ...}`
  tuple instead of a `[key1: value1, key2: value2, ...]` keyword list.
  """
  def flat_parse(input, parsers)
  def flat_parse(doc = %Document{}, parsers) do
    with {:ok, list} <- parse_doc(doc, parsers) do
      output =
        list
        |> Keyword.values
        |> Enum.reverse

      List.to_tuple([:ok | output])
    end
  end
  def flat_parse(params = %{}, parsers) do
    with {:ok, list} <- parse_params(params, parsers) do
      output =
        list
        |> Keyword.values
        |> Enum.reverse

      List.to_tuple([:ok | output])
    end
  end

  @doc """
  Makes sure there are no unknown params passed to controller action.
  """
  def assert_blank_params(params) do
    with {:ok, []} <- parse(params, []) do
      :ok
    end
  end

  @doc """
  Renames keys in the parser output.
  """
  def map_parsed_options(parser_result, mapping) do
    with {:ok, opts} <- parser_result do
      updated_opts = Enum.reduce(mapping, opts, fn {source, target}, current_opts ->
        case Keyword.fetch(current_opts, source) do
          {:ok, value} ->
            current_opts
            |> Keyword.delete(source)
            |> Keyword.put(target, value)
          :error ->
            current_opts
        end
      end)

      {:ok, updated_opts}
    end
  end

  defp parse_params(params, parsers) do
    {params, [], []}
    |> pop_and_parse_keys(parsers)
    |> pop_unknown()
    |> close_params()
  end

  defp parse_doc(%{data: resource = %{}}, parsers) do
    resource
    |> parse_resource(parsers)
    |> prefix_error_pointers("/data/")
  end
  defp parse_doc(_doc, _parsers) do
    {:error, :invalid_pointers, [required: "/data"]}
  end

  defp parse_resource(resource, parsers) do
    {root_output, root_errors} = parse_resource_root(resource, parsers)
    {attribute_output, attribute_errors} = parse_resource_nested(resource, parsers, :attributes)
    {relationship_output, relationship_errors} =
      parse_resource_nested(resource, parsers, :relationships)

    output = relationship_output ++ attribute_output ++ root_output
    errors = root_errors ++ attribute_errors ++ relationship_errors

    close_resource({output, errors})
  end

  defp parse_resource_root(resource, all_parsers) do
    parsers = Keyword.drop(all_parsers, [:attributes, :relationships])
    input = Map.from_struct(resource)

    {_, output, errors} = pop_and_parse_keys({input, [], []}, parsers, stringify: false)

    {output, errors}
  end

  defp parse_resource_nested(resource, all_parsers, key) do
    parsers = Keyword.get(all_parsers, key, [])
    attributes = Map.get(resource, key, %{})

    {output, errors} =
      {attributes, [], []}
      |> pop_and_parse_keys(parsers)
      |> pop_unknown()

    prefixed_errors = prefix_error_pointers(errors, "#{key}/")

    {output, prefixed_errors}
  end

  defp prefix_error_pointers(payload, prefix) when is_tuple(payload) do
    with {:error, reason, pointers} when is_list(pointers) <- payload do
      {:error, reason, prefix_error_pointers(pointers, prefix)}
    end
  end
  defp prefix_error_pointers(errors, prefix) when is_list(errors) do
    Enum.map(errors, &prefix_error_pointer(&1, prefix))
  end

  defp prefix_error_pointer({reason, key}, prefix), do: {reason, "#{prefix}#{key}"}

  defp pop_and_parse_keys(payload, key_parsers, opts \\ []) do
    stringify = Keyword.get(opts, :stringify, true)

    Enum.reduce(key_parsers, payload, &pop_and_parse_keys_each(&1, &2, stringify))
  end

  defp pop_and_parse_keys_each({key, parser}, current_payload, stringify) do
    final_parser = case parser do
      func when is_function(parser) -> func
      list when is_list(list) -> &parse_in_sequence(&1, list)
    end

    pop_and_parse_key(current_payload, {key, stringify}, final_parser, key)
  end

  defp pop_and_parse_key({map, output, errors}, {input_key, stringify}, parser_func, output_key) do
    {{input_value, remaining_map}, error_key} = if stringify do
      pop_maybe_dasherized(map, Atom.to_string(input_key))
    else
      {Map.pop(map, input_key), Atom.to_string(input_key)}
    end

    case parser_func.(input_value) do
      {:ok, parser_output} ->
        final_output = Keyword.put_new(output, output_key, parser_output)
        {remaining_map, final_output, errors}
      {:error, new_errors} when is_list(new_errors) ->
        prefixed_new_errors = Enum.map(new_errors, fn {reason, pointer} ->
          {reason, "#{error_key}/#{pointer}"}
        end)
        final_errors = Keyword.merge(errors, prefixed_new_errors)
        {remaining_map, output, final_errors}
      {:error, reason} ->
        final_errors = Keyword.put_new(errors, reason, error_key)
        {remaining_map, output, final_errors}
    end
  end

  defp parse_in_sequence(input, [first_parser | other_parsers]) do
    Enum.reduce(other_parsers, first_parser.(input), &parse_in_sequence_each/2)
  end

  defp parse_in_sequence_each(_next_parser, {:error, reason}), do: {:error, reason}
  defp parse_in_sequence_each(next_parser, {:ok, prev_output}), do: next_parser.(prev_output)

  defp pop_maybe_dasherized(map, key) do
    if Map.has_key?(map, key) do
      {Map.pop(map, key), key}
    else
      dasherized_key = String.replace(key, "_", "-")
      {Map.pop(map, dasherized_key), dasherized_key}
    end
  end

  defp pop_unknown({map, output, errors}) do
    new_errors =
      map
      |> Enum.filter(fn {key, _value} -> key != "data" end)
      |> Enum.map(fn {key, _value} -> {:unknown, key} end)

    {output, errors ++ new_errors}
  end

  defp close_params({output, []}), do: {:ok, output}
  defp close_params({_output, errors}), do: {:error, :invalid_parameters, errors}

  defp close_resource({output, []}), do: {:ok, output}
  defp close_resource({_output, errors}), do: {:error, :invalid_pointers, errors}

  defp drop_empty_opts(opts_tuple) do
    with {:ok, opts} <- opts_tuple do
      filtered_opts =
        Enum.filter(opts, fn
          {_key, nil} -> false
          {_key, []} -> false
          {_key, _value} -> true
        end)

      {:ok, filtered_opts}
    end
  end
end
