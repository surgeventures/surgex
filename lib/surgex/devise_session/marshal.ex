defmodule Surgex.DeviseSession.Marshal do
  @moduledoc false

  def encode(value) do
    {:ok, ExMarshal.encode(value)}
  end

  def decode(value) do
    {:ok, ExMarshal.decode(value)}
  end
end
