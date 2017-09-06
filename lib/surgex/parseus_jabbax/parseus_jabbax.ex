defmodule Surgex.Parseus.Jabbax do
  use Jabbax.Document
  import Surgex.Parseus

  defmacro __using__(_) do
    quote do
      import Surgex.Parseus
      import Surgex.Parseus.Jabbax, except: [build_errors_document: 1]
    end
  end

  def build_errors_document(set = %{input: %Document{}}) do
    %Document{errors: build_document_errors(set)}
  end
  def build_errors_document(set = %{input: %{}}) do
    %Document{errors: build_param_errors(set)}
  end

  defp build_document_errors(set = %{errors: errors}) do
    Enum.map(errors, fn {output_key, error} ->
      %Error{
        code: format_error_code(error),
        source: %ErrorSource{pointer: format_error_pointer(set, output_key)}
      }
    end)
  end

  defp build_param_errors(set = %{errors: errors}) do
    Enum.map(errors, fn {output_key, error} ->
      %Error{
        code: format_error_code(error),
        source: %ErrorSource{parameter: format_error_parameter(set, output_key)}
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

  defp format_error_parameter(set, output_key) do
    [first, rest] =
      set
      |> get_input_path(output_key)
      |> Enum.map(&map_input_key/1)

    first <>
      rest
      |> Enum.map(fn param -> "[#{param}]" end)
      |> Enum.join()
  end

  defp format_error_pointer(set, output_key) do
    path =
      set
      |> get_input_path(output_key)
      |> Enum.map(&map_input_key/1)

    "/" <> Enum.join(path, "/")
  end

  defp map_input_key({:key, key}), do: key
  defp map_input_key(key), do: key

  def cast_resource(conn, func) do
    conn.assigns[:doc]
    |> cast_in({:key, :data}, func)
    |> resolve()
  end

  def cast_resource_relationship_id(input, rel_name, output_key) do
    cast_in(input, [{:key, :relationships}, rel_name], fn input ->
      input
      |> ensure_in_relationship()
      |> cast_in({:key, :data}, &cast_resource_relationship_id_data(&1, output_key))
    end)
  end

  defp cast_resource_relationship_id_data(input, output_key) do
    input
    |> ensure_map()
    |> cast(:id)
    |> parse_integer(:id)
    |> validate_number(:id, type: :integer, greater_than: 0)
    |> rename(:id, output_key)
  end

  def cast_resource_attributes(input, cast_keys) do
    cast_in(input, {:key, :attributes}, fn input ->
      cast(input, cast_keys)
    end)
  end

  defp ensure_map(struct = %{__struct__: _}), do: Map.from_struct(struct)
  defp ensure_map(any), do: any

  defp ensure_in_relationship(input = %ResourceId{}), do: %Relationship{data: input}
  defp ensure_in_relationship(any), do: any
end
