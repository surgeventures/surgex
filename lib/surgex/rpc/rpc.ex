defmodule Surgex.RPC do
  @moduledoc """
  Remote procedure call system based on Protocol Buffers.

  Depending on whether you want to implement an RPC client or server, check out following modules:

  - `Surgex.RPC.Client`: calls services in remote systems
  - `Surgex.RPC.Server`: responds to service calls from remote systems

  Also, ensure that you have picked and configured one of available transport adapters:

  - `Surgex.RPC.AMQPAdapter`: transports RPC calls through AMQP messaging queue
  - `Surgex.RPC.HTTPAdapter`: transports RPC calls through HTTP requests protected by secret header

  """
end
