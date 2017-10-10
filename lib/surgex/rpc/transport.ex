defmodule Surgex.RPC.Transport do
  @moduledoc false

  alias Surgex.RPC.{AMQPAdapter, HTTPAdapter}

  def resolve(:amqp), do: AMQPAdapter
  def resolve(:http), do: HTTPAdapter
  def resolve(adapter_mod), do: adapter_mod

  def get_server_mod(adapter_mod) do
    :"#{adapter_mod}.Server"
  end
end
