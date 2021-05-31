case Code.ensure_loaded(Jabbax) do
  {:module, _} ->
    defmodule Surgex.Changeset do
      @moduledoc """
      Tools for working with Ecto changesets.
      """

      use Jabbax.Document

      @doc """
      Builds Jabbax document that describes changeset errors.
      """
      def build_errors_document(changeset) do
        errors_map = Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} -> {msg, opts} end)
        %Document{errors: build_errors(errors_map)}
      end

      defp build_errors(map, prefixes \\ []) do
        map
        |> Enum.map(& build_error(&1, prefixes))
        |> List.flatten()
      end

      defp build_error({field, map}, prefixes) when is_map(map) do
        build_errors(map, [field | prefixes])
      end

      defp build_error({field, list}, prefixes) do
        Enum.map(list, fn {text, info} ->
          %Error{
            code: get_error_code(text, info[:validation]),
            source: build_error_source(field, prefixes)
          }
        end)
      end

      defp get_error_code("has already been taken", nil), do: "taken"
      defp get_error_code(_, :required), do: "required"
      defp get_error_code(_, nil), do: "invalid"
      defp get_error_code(_, :cast), do: "invalid"
      defp get_error_code(_, suffix), do: "invalid_#{suffix}"

      defp build_error_source(field, []), do: ErrorSource.from_attribute(field)

      defp build_error_source(field, prefixes) do
        base =
        prefixes
        |> Enum.reverse()
        |> Enum.map(& "/relationships/#{&1}/data")
        |> Enum.join("")

        pointer = "#{base}/attributes/#{field}"
        %ErrorSource{pointer: pointer}
      end
    end

  _ ->
    nil
end
