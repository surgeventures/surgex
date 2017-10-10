defmodule Surgex.RPC.Utils do
  alias Surgex.Config, as: SurgexConfig
  alias Surgex.RPC.{AMQPAdapter, HTTPAdapter}

  def get_config(opts, key, default \\ nil) do
    opts
    |> Keyword.get(key, default)
    |> SurgexConfig.parse()
  end

  def get_config!(opts, key) do
    opts
    |> Keyword.fetch!(key)
    |> SurgexConfig.parse()
  end

  def mod_defined?(mod) do
    case Code.ensure_loaded(mod) do
      {:module, _} -> true
      _ -> false
    end
  end

  def process_service(service_mod, request_buf, request_mod) do
    request_buf
    |> request_mod.decode()
    |> service_mod.call()
  end
  def process_service(service_mod, request_buf, request_mod, response_mod) do
    case process_service(service_mod, request_buf, request_mod) do
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

  def resolve_adapter(:amqp), do: AMQPAdapter
  def resolve_adapter(:http), do: HTTPAdapter
  def resolve_adapter(adapter_mod), do: adapter_mod

  def resolve_adapter_server_mod(adapter_mod) do
    :"#{adapter_mod}.Server"
  end

  def resolve_adapter_client_mod(adapter_mod) do
    :"#{adapter_mod}.Client"
  end
end
