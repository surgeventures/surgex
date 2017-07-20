defmodule Surgex.DeviseSession.MarshalSerializer do
  @moduledoc """
  Share a session with a Rails app using Ruby's Marshal format.
  """

  def encode(value) do
    {:ok, ExMarshal.encode(value)}
  end

  def decode(value) do
    {:ok, ExMarshal.decode(value)}
  end
end
