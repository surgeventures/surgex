defmodule Surgex.Parseus.ParseProcessor do
  @moduledoc false

  alias Surgex.Parseus.{Error, Set}

  def call(set, keys, parser, opts) when is_list(keys) do
    Enum.reduce(keys, set, &call(&2, &1, parser, opts))
  end
  def call(set = %Set{output: output, errors: errors}, key, parser, opts) do
    with false <- Keyword.has_key?(errors, key),
         {:ok, old_value} <- Keyword.fetch(output, key)
    do
      parser
      |> call_parser(old_value, opts)
      |> handle_result(set, key, parser)
    else
      _ -> set
    end
  end

  defp call_parser(parser, value, []), do: call_parser_with_args(parser, [value])
  defp call_parser(parser, value, opts), do: call_parser_with_args(parser, [value, opts])

  defp call_parser_with_args(parser, args) when is_atom(parser), do: apply(parser, :call, args)
  defp call_parser_with_args(parser, args) when is_function(parser), do: apply(parser, args)

  defp handle_result({:ok, new_value}, set = %Set{output: output}, key, _parser) do
    new_output = Keyword.put(output, key, new_value)
    %{set | output: new_output}
  end
  defp handle_result(:error, set, key, parser) do
    replace_output_with_error(set, key, source: parser)
  end
  defp handle_result({:error, reason}, set, key, parser) do
    replace_output_with_error(set, key, source: parser, reason: reason)
  end
  defp handle_result({:error, reason, info}, set, key, parser) do
    replace_output_with_error(set, key, source: parser, reason: reason, info: info)
  end

  defp replace_output_with_error(set = %Set{output: output, errors: errors}, key, attrs) do
    new_error = Error.build(attrs)
    new_errors = [{key, new_error} | errors]
    new_output = Keyword.delete(output, key)

    %{set | errors: new_errors, output: new_output}
  end
end
