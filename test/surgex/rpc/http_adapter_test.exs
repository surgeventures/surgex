defmodule Surgex.RPC.HTTPAdapterTest do
  use ExUnit.Case, async: false
  import Mock
  alias Surgex.RPC.HTTPAdapter

  @expected_headers [{"X-RPC-Secret", "topsecret"}]

  @expected_body Poison.encode!(%{
    "service_name" => "x",
    "request_buf_b64" => Base.encode64("bindata")
  })

  describe "call/2" do
    test "success" do
      mocked_post = fn url, body, headers ->
        assert url == "http://example.com/rpc"
        assert headers == @expected_headers
        assert body == @expected_body

        response_body = Poison.encode!(%{
          "response_buf_b64" => Base.encode64("bindata_out")
        })

        %{
          status_code: 200,
          body: response_body
        }
      end

      opts = [url: "http://example.com/rpc", secret: "topsecret"]

      with_mock HTTPoison, [post!: mocked_post] do
        response = HTTPAdapter.call({"x", "bindata"}, opts)
        assert response == {:ok, "bindata_out"}
      end
    end

    test "failure" do
      mocked_post = fn _, _, _ ->
        response_body = Poison.encode!(%{
          "errors" => [%{
            "reason" => ":code",
            "pointer" => [["struct", "user"], ["repeated", 0]]
          }, %{
            "reason" => "some text"
          }, %{
            "reason" => ":some_non_existing_atom_a9bh09"
          }]
        })

        %{
          status_code: 200,
          body: response_body
        }
      end

      opts = [url: "http://example.com/rpc", secret: "topsecret"]

      with_mock HTTPoison, [post!: mocked_post] do
        response = HTTPAdapter.call({"x", "bindata"}, opts)
        assert response == {:error, [
          {:code, [struct: "user", repeated: 0]},
          {"some text", nil},
          {"some_non_existing_atom_a9bh09", nil}
        ]}
      end
    end
  end
end
