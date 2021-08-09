defmodule Surgex.Parser.ResourceIdParser do
  @moduledoc false

  alias Surgex.Parser.IdParser

  @spec call(term()) :: {:ok, integer | nil} | {:error, Keyword.t()}
  def call(nil), do: {:ok, nil}

  def call(%{id: ""}), do: {:error, [required: "id"]}

  def call(%{id: id_string}) when is_binary(id_string) do
    with {:error, reason} <- IdParser.call(id_string) do
      {:error, [{reason, "id"}]}
    end
  end

  def call(_), do: {:error, [required: "id"]}
end
