defmodule Surgex.RPC.SampleClient do
  @moduledoc false

  use Surgex.RPC.Client

  transport :http, url: "http://example.com/rpc", secret: "xyz"

  proto "./test/support/surgex/rpc/create_user.proto"
end
