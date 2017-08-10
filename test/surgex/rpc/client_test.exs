defmodule Surgex.RPC.ClientTest do
  use ExUnit.Case
  alias Surgex.RPC.{
    SampleClient,
    TransportError,
  }
  alias Surgex.RPC.SampleClient.CreateUser

  describe "call/0" do
    test "unmocked transport" do
      request = %CreateUser.Request{
        user: %CreateUser.Request.User{
          name: "some guy",
          gender: :MALE
        }
      }

      assert_raise TransportError, "HTTP request failed with code 404", fn ->
        SampleClient.call(request)
      end
    end
  end
end
