defmodule Surgex.RPC.Config do
  alias Surgex.Config, as: SurgexConfig

  def get(opts, key, default \\ nil) do
    opts
    |> Keyword.get(key, default)
    |> SurgexConfig.parse()
  end

  def get!(opts, key) do
    opts
    |> Keyword.fetch!(key)
    |> SurgexConfig.parse()
  end
end
