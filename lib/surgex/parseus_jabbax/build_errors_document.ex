defmodule Surgex.ParseusJabbax.BuildErrorsDocument do
  use Jabbax.Document
  import Surgex.Parseus

  def call(set = %{input: %Document{}}) do
    %Document{errors: build_document_errors(set)}
  end
  def call(set = %{input: %{}}) do
    %Document{errors: build_param_errors(set)}
  end

  defp build_document_errors(set) do
    flat_errors = flatten_errors(set)

    IO.inspect set.errors
    IO.inspect flat_errors

    Enum.map(flat_errors, fn {output_path, error} ->
      %Error{
        code: format_error_code(error),
        source: %ErrorSource{pointer: format_error_pointer(set, output_path)}
      }
    end)
  end

  defp build_param_errors(set) do
    flat_errors = flatten_errors(set)

    Enum.map(flat_errors, fn {output_path, error} ->
      %Error{
        code: format_error_code(error),
        source: %ErrorSource{parameter: format_error_parameter(set, output_path)}
      }
    end)
  end

  defp format_error_code(%{reason: nil, source: source}), do: format_error_source(source)
  defp format_error_code(%{reason: reason}), do: reason

  defp format_error_source(source) when is_atom(source) do
    source
    |> to_string()
    |> format_error_source()
  end
  defp format_error_source(source) do
    prefix =
      source
      |> String.replace(~r/_parser$/, "")
      |> String.replace(~r/_validator$/, "")

    case prefix do
      "required" -> prefix
      _ -> "invalid_" <> prefix
    end
  end

  defp format_error_parameter(set, output_path) do
    [first, rest] =
      set
      |> get_input_path(output_path)
      |> Enum.filter(&filter_input_key/1)
      |> Enum.map(&map_input_key/1)

    first <>
      rest
      |> Enum.map(fn param -> "[#{param}]" end)
      |> Enum.join()
  end

  defp format_error_pointer(set, output_path) do
    path =
      set
      |> get_input_path(output_path)
      |> Enum.filter(&filter_input_key/1)
      |> Enum.map(&map_input_key/1)

    "/" <> Enum.join(path, "/")
  end

  defp filter_input_key({:error, _}), do: false
  defp filter_input_key(_), do: true

  defp map_input_key({:key, key}), do: key
  defp map_input_key(key), do: key
end
