defmodule Surgex.RPC.Client do
  alias Surgex.RPC.Transport

  def call(service_spec, request) when is_list(request) do
    request_mod = Keyword.fetch!(service_spec, :request)

    call(service_spec, apply(request_mod, :new, [request]))
  end
  def call(service_spec, request) do
    service_name = Keyword.fetch!(service_spec, :service)
    request_mod = Keyword.fetch!(service_spec, :request)
    response_mod = Keyword.fetch!(service_spec, :response)
    request_buf = apply(request_mod, :encode, [request])

    case Transport.call(service_name, request_buf) do
      {:ok, response_buf} ->
        response = apply(response_mod, :decode, [response_buf])
        {:ok, response}

      {:error, errors} ->
        {:error, errors}
    end
  end

  def call!(service_spec, request) do
    case call(service_spec, request) do
      {:ok, response} ->
        response
      {:error, errors} ->
        raise("Remote call rejected: #{inspect errors}")
    end
  end
end
