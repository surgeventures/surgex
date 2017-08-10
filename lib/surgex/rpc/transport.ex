defmodule Surgex.RPC.Transport do
  alias Surgex.RPC.HTTPAdapter

  def call(request, opts) do
    {adapter, adapter_opts} = Keyword.pop(opts, :adapter)

    case adapter do
      :http ->
        HTTPAdapter.call(request, adapter_opts)
      adapter_mod ->
        adapter_mod.call(request, adapter_opts)
    end
  end
end
