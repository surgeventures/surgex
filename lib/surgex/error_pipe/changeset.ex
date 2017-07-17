defmodule Surgex.ErrorPipe.Changeset do
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

  defp build_errors(_changeset = %{errors: errors}) do
    Enum.map(errors, &build_error/1)
  end

  defp build_error({field, {text, info}}) do
    %Error{
      code: get_error_code(text, info[:validation]),
      source: ErrorSource.from_attribute(field)
    }
  end

  defp get_error_code("has already been taken", nil), do: "taken"
  defp get_error_code(_, :required), do: "required"
  defp get_error_code(_, nil), do: "invalid"
  defp get_error_code(_, :cast), do: "invalid"
  defp get_error_code(_, suffix), do: "invalid_#{suffix}"
end
