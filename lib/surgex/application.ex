defmodule Surgex.Application do
  use Application
  use GenServer
  require Logger

  def start(_type, _args) do
    GenServer.start_link(__MODULE__, nil)
  end

  def init(_) do
    Surgex.Sentry.init()

    {:ok, nil, :hibernate}
  end
end
