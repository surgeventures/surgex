defmodule Surgex.Parser.IncludeParser do
  @moduledoc """
  Parses the JSON API's include parameter according to the
  [JSON API spec](http://jsonapi.org/format/#fetching-includes).

  Produces a list of includes constrained to the provided relationship paths.
  """

  def call(nil, _spec), do: {:ok, []}
  def call("", _spec), do: {:ok, []}
  def call(input, [allowed_path]) when is_binary(input) do
    if input == Atom.to_string(allowed_path) do
      {:ok, [allowed_path]}
    else
      {:error, :invalid_relationship_path}
    end
  end
  def call(_input, spec) do
    raise(ArgumentError, "Path specification not supported: #{inspect spec}")
  end

  def flatten({:ok, opts}, key) do
    case Keyword.pop(opts, key) do
      {nil, _} ->
        {:ok, opts}
      {value_list, rem_opts} when is_list(value_list) ->
        new_opts =
          value_list
          |> Enum.map(fn value -> {String.to_atom("#{key}_#{value}"), true} end)
          |> Keyword.merge(rem_opts)
        {:ok, new_opts}
    end
  end
  def flatten(input, _key), do: input
end
