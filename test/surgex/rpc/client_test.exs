defmodule Surgex.RPC.ClientTest do
  use ExUnit.Case
  alias Surgex.RPC.SampleClient.CreateUser

  describe "call/0" do
    test "successful call" do
      request = %CreateUser.Request{
        user: %CreateUser.Request.User{
          name: "some guy",
          gender: :MALE
        }
      }

      assert_raise RuntimeError, "HTTP request failed with code 404", fn ->
        CreateUser.call(request)
      end
    end
  end
end
