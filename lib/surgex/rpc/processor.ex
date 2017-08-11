defmodule Surgex.RPC.Processor do
  @moduledoc false

  def call(service_mod, request_buf, request_mod, response_mod) do
    service_result =
      request_buf
      |> request_mod.decode()
      |> service_mod.call()

    case service_result do
      :ok ->
        {:ok, response_mod.encode(response_mod.new())}
      {:ok, response_struct} ->
        {:ok, response_mod.encode(response_struct)}
      :error ->
        {:error, [error: nil]}
      {:error, errors} when is_list(errors) ->
        {:error, Enum.map(errors, &normalize_error/1)}
      {:error, error} ->
        {:error, [normalize_error(error)]}
    end
  end

  defp normalize_error(reason) when is_atom(reason) or is_binary(reason), do: {reason, nil}
  defp normalize_error({reason, pointer}), do: {reason, pointer}
end
