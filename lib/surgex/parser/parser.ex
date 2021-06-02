defmodule Surgex.Parser do
  @moduledoc """
  Parses, casts and catches errors in the web request input, such as params or JSON API body.

  ## Usage

  In order to use it, you should import the `Surgex.Parser` module, possibly in the `controller`
  macro in the `web.ex` file belonging to your Phoenix project, which will make functions like
  `parse` available in all controllers.

  Then, you should start implementing functions for parsing params or documents for specific
  controller actions. Those functions will serve as documentation crucial for understanding specific
  action's input, so it's best to keep them close to the relevant action. For example:

      def index(conn, params) do
        with {:ok, opts} <- parse_index_params(params) do
          render(conn, locations: Marketplace.search_locations(opts))
        else
          {:error, :invalid_parameters, params} -> {:error, :invalid_parameters, params}
        end
      end

      defp parse_index_params(params) do
        parse params,
          query: [:string, :required],
          center: :geolocation,
          box: :box,
          category_id: :id,
          subcategory_ids: :id_list,
          sort: {:sort, ~w{price_min published_at distance}a},
          page: :page
      end

  The second argument to `parse/2` and `flat_parse/2` is a param spec in which keys are resulting
  option names and values are parser functions, atoms, tuples or lists used to process specific
  parameter. Here's how each work:

  - **parser functions** are functions that take the input value as first argument and can take
    arbitrary amount of additional arguments as parser options; in order to pass such parser it's
    best to use the `&` operator in format `&parser/1` or in case of parser options
    `&parser(&1, opts...)`

  - **parser atoms** point to built-in parsers by looking up a
    `Surgex.Parser.<camelized-name>Parser` module and invoking the `call` function within it,
    where the `call` function is just a parser function described above; for example `:integer` is
    an equivalent to `&Surgex.Parser.IntegerParser.call/1`

  - **parser tuples** allow to pass additional options to built-in parsers; the tuple starts with
    the parser atom described above, followed by parser arguments matching the number of additional
    arguments consumed by the parser; for example `{:sort, ~w{price_min published_at}a}`

  - **parser lists** allow to pass a list of parser functions, atoms or tuples, all of which will be
    parsed in a sequence in which the output from previous parser is piped to the next one and in
    which the first failure stops the whole pipe; for example `[:integer, :required]`
  """

  @doc """
  Parses controller action input (parameters, documents) with a given set of parsers.

  Returns a keyword list with parsed options.
  """
  @spec parse(nil, any) :: {:error, :empty_input}
  @spec parse(map, list) ::
          {:ok, any} | {:error, :invalid_parameters, list} | {:error, :invalid_pointers, list}
  def parse(input, parsers)

  def parse(resource = %{__struct__: Jabbax.Document.Resource}, parsers) do
    parse_resource(resource, parsers)
  end

  def parse(doc = %{__struct__: Jabbax.Document}, parsers) do
    parse_doc(doc, parsers)
  end

  def parse(params = %{}, parsers) do
    parse_params(params, parsers)
  end

  def parse(nil, _parsers), do: {:error, :empty_input}

  @doc """
  Parses controller action input into a flat structure.

  This function takes the same input as `parse/2` but it returns a `{:ok, value1, value2, ...}`
  tuple instead of a `[key1: value1, key2: value2, ...]` keyword list.
  """
  @spec flat_parse(nil, any) :: {:error, :empty_input}
  @spec flat_parse(map, list) ::
          {:ok, any} | {:error, :invalid_parameters, list} | {:error, :invalid_pointers, list}
  def flat_parse(input, parsers)

  def flat_parse(doc = %{__struct__: Jabbax.Document}, parsers) do
    with {:ok, list} <- parse_doc(doc, parsers, include_missing: true) do
      output =
        list
        |> Keyword.values()
        |> Enum.reverse()

      List.to_tuple([:ok | output])
    end
  end

  def flat_parse(params = %{}, parsers) do
    with {:ok, list} <- parse_params(params, parsers, include_missing: true) do
      output =
        list
        |> Keyword.values()
        |> Enum.reverse()

      List.to_tuple([:ok | output])
    end
  end

  def flat_parse(nil, _parsers), do: {:error, :empty_input}

  @doc """
  Makes sure there are no unknown params passed to controller action.
  """
  @spec assert_blank_params(map) ::
          :ok | {:error, :invalid_parameters, list} | {:error, :invalid_pointers, list}
  def assert_blank_params(params) do
    with {:ok, []} <- parse(params, []) do
      :ok
    end
  end

  @doc """
  Renames keys in the parser output.
  """
  @spec map_parsed_options({:error, any}, any) :: {:error, any}
  @spec map_parsed_options({:ok, any}, any) :: {:ok, any}
  def map_parsed_options(parser_result, mapping) do
    with {:ok, opts} <- parser_result do
      updated_opts =
        Enum.reduce(mapping, opts, fn {source, target}, current_opts ->
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

  defp parse_params(params, parsers, opts \\ []) do
    {params, [], []}
    |> pop_and_parse_keys(parsers, opts)
    |> pop_unknown()
    |> close_params()
  end

  defp parse_doc(doc, parsers, opts \\ [])

  defp parse_doc(%{data: resource = %{}}, parsers, opts) do
    resource
    |> parse_resource(parsers, opts)
    |> prefix_error_pointers("/data/")
  end

  defp parse_doc(_doc, _parsers, _opts) do
    {:error, :invalid_pointers, [required: "/data"]}
  end

  defp parse_resource(resource, parsers, opts \\ []) do
    {root_output, root_errors} = parse_resource_root(resource, parsers, opts)

    {attribute_output, attribute_errors} =
      parse_resource_nested(resource, parsers, :attributes, opts)

    {relationship_output, relationship_errors} =
      parse_resource_nested(resource, parsers, :relationships, opts)

    output = relationship_output ++ attribute_output ++ root_output
    errors = root_errors ++ attribute_errors ++ relationship_errors

    close_resource({output, errors})
  end

  defp parse_resource_root(resource, all_parsers, opts) do
    parsers = Keyword.drop(all_parsers, [:attributes, :relationships])
    input = Map.from_struct(resource)

    {_, output, errors} = pop_and_parse_keys({input, [], []}, parsers, [stringify: false] ++ opts)

    {output, errors}
  end

  defp parse_resource_nested(resource, all_parsers, key, opts) do
    parsers = Keyword.get(all_parsers, key, [])
    attributes = Map.get(resource, key, %{})

    {output, errors} =
      {attributes, [], []}
      |> pop_and_parse_keys(parsers, opts)
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

  defp pop_and_parse_keys(payload, key_parsers, opts) do
    Enum.reduce(key_parsers, payload, &pop_and_parse_keys_each(&1, &2, opts))
  end

  defp pop_and_parse_keys_each({key, parser}, current_payload, opts) do
    pop_and_parse_key(current_payload, {key, opts}, parser, key)
  end

  # credo:disable-for-next-line Credo.Check.Refactor.ABCSize
  defp pop_and_parse_key({map, output, errors}, {input_key, opts}, parser, output_key) do
    stringify = Keyword.get(opts, :stringify, true)
    include_missing = Keyword.get(opts, :include_missing, false)

    {{input_value, remaining_map}, used_key} = pop(map, input_key, stringify)
    had_key = Map.has_key?(map, used_key)
    drop_nil = not include_missing and not had_key

    case call_parser(parser, input_value) do
      {:ok, nil} ->
        if drop_nil do
          {remaining_map, output, errors}
        else
          final_output = Keyword.put_new(output, output_key, nil)
          {remaining_map, final_output, errors}
        end

      {:ok, parser_output} ->
        final_output = Keyword.put_new(output, output_key, parser_output)
        {remaining_map, final_output, errors}

      {:error, new_errors} when is_list(new_errors) ->
        prefixed_new_errors =
          Enum.map(new_errors, fn {reason, pointer} ->
            {reason, "#{used_key}/#{pointer}"}
          end)

        final_errors = prefixed_new_errors ++ errors
        {remaining_map, output, final_errors}

      {:error, reason} ->
        final_errors = [{reason, used_key} | errors]
        {remaining_map, output, final_errors}
    end
  end

  defp parse_in_sequence(input, [first_parser | other_parsers]) do
    Enum.reduce(other_parsers, call_parser(first_parser, input), &parse_in_sequence_each/2)
  end

  defp parse_in_sequence_each(_next_parser, {:error, reason}), do: {:error, reason}

  defp parse_in_sequence_each(next_parser, {:ok, prev_output}) do
    call_parser(next_parser, prev_output)
  end

  defp call_parser(parsers, input) when is_list(parsers), do: parse_in_sequence(input, parsers)
  defp call_parser(parser, input) when is_function(parser), do: parser.(input)
  defp call_parser(parser, input) when is_atom(parser), do: call_parser({parser}, input)

  defp call_parser(parser_tuple, input) when is_tuple(parser_tuple) do
    [parser_name | parser_args] = Tuple.to_list(parser_tuple)

    parser_camelized =
      parser_name
      |> Atom.to_string()
      |> Macro.camelize()

    parser_module = String.to_existing_atom("Elixir.Surgex.Parser.#{parser_camelized}Parser")

    apply(parser_module, :call, [input | parser_args])
  end

  defp pop(map, key, stringify)

  defp pop(map, key, false) do
    {Map.pop(map, key), key}
  end

  defp pop(map, key, true) do
    key_string = Atom.to_string(key)

    if Map.has_key?(map, key_string) do
      {Map.pop(map, key_string), key_string}
    else
      dasherized_key = String.replace(key_string, "_", "-")
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
end
