defmodule Surgex.ParseusJabbax do
  @moduledoc """
  Combines Parseus and Jabbax for end-to-end JSON API parsing and error handling.
  """

  use Jabbax.Document
  import Surgex.Parseus
  alias __MODULE__.{
    BuildErrorsDocument,
    IncludeParser,
    SortParser,
  }

  defmacro __using__(_) do
    quote do
      import Surgex.Parseus
      import Surgex.ParseusJabbax, except: [build_errors_document: 1]
    end
  end

  def build_errors_document(set) do
    BuildErrorsDocument.call(set)
  end

  defp cast_document_data(doc, func) do
    cast_in(doc, {:key, :data}, func)
  end

  def cast_resource_attributes(input, cast_keys) do
    cast_in(input, {:key, :attributes}, fn input ->
      cast(input, cast_keys)
    end)
  end

  def cast_resource_related_id(input, rel_name, custom_output_key \\ nil) do
    output_key = custom_output_key || make_related_id_key(rel_name)

    cast_in(input, [{:key, :relationships}, rel_name], fn input ->
      input
      |> ensure_in_relationship()
      |> cast_in({:key, :data}, &cast_resource_related_id_data(&1, output_key))
    end)
  end

  defp make_related_id_key(rel_name) do
    base =
      rel_name
      |> Macro.underscore
      |> String.replace("-", "_")

    String.to_atom("#{base}_id")
  end

  defp ensure_in_relationship(input = %ResourceId{}), do: %Relationship{data: input}
  defp ensure_in_relationship(any), do: any

  defp cast_resource_related_id_data(input, output_key) do
    input
    |> ensure_map()
    |> cast(:id)
    |> parse_integer(:id)
    |> validate_number(:id, type: :integer, greater_than: 0)
    |> rename(:id, output_key)
  end

  defp ensure_map(struct = %{__struct__: _}), do: Map.from_struct(struct)
  defp ensure_map(any), do: any

  def fork_include(set, source_key, include, custom_target_key \\ nil) do
    target_key = custom_target_key || make_include_key(include)

    set
    |> fork(source_key, target_key)
    |> map(target_key, &Enum.member?(&1, include))
  end

  defp make_include_key(include) when is_list(include) do
    include
    |> Enum.join("_")
    |> make_include_key()
  end
  defp make_include_key(include) do
    :"include_#{include}"
  end

  def parse_include(set, key_or_keys, allowed_relationships) do
    parse(set, key_or_keys, IncludeParser, allowed_relationships)
  end

  def parse_sort(set, key_or_keys, allowed_keys) do
    parse(set, key_or_keys, SortParser, allowed_keys)
  end

  def resolve_document(conn, func) do
    conn.assigns[:doc]
    |> cast_document_data(func)
    |> resolve()
  end
  def resolve_document(conn, tuple_keys, func) do
    conn.assigns[:doc]
    |> cast_document_data(func)
    |> resolve_tuple(tuple_keys)
  end
end
