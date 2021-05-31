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
        %Document{errors: build_errors(changeset)}
      end

      defp build_errors(changeset) do
        changeset
        |> Ecto.Changeset.traverse_errors(fn {msg, opts} -> {msg, opts} end)
        |> Enum.map(&build_error/1)
        |> List.flatten()
      end

      defp build_error({field, list}) do
        Enum.map(list, fn {text, info} ->
          %Error{
            code: get_error_code(text, info[:validation]),
            source: ErrorSource.from_attribute(field)
          }
        end)
      end

      defp get_error_code("has already been taken", nil), do: "taken"
      defp get_error_code(_, :required), do: "required"
      defp get_error_code(_, nil), do: "invalid"
      defp get_error_code(_, :cast), do: "invalid"
      defp get_error_code(_, suffix), do: "invalid_#{suffix}"
    end

  _ ->
    nil
end
