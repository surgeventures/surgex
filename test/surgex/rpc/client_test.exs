defmodule Surgex.RPC.SampleClientWithCustomAdapter.Adapter do
  def call(_, opts) do
    raise("Dummy adapter (opts: #{inspect(opts)})")
  end
end

defmodule Surgex.RPC.SampleClientWithCustomAdapter do
  @moduledoc false

  use Surgex.RPC.Client

  transport(__MODULE__.Adapter, x: "y")

  proto(:empty)

  service(
    proto: [from: Path.expand("./proto/empty.proto", __DIR__)],
    service_name: "create_user",
    service_mod: __MODULE__.EmptyService,
    request_mod: __MODULE__.EmptyService.Request,
    response_mod: __MODULE__.EmptyService.Response,
    mock_mod: __MODULE__.EmptyService.Mock
  )
end

defmodule Surgex.RPC.SampleClientWithoutService do
  @moduledoc false

  use Surgex.RPC.Client

  transport(__MODULE__.Adapter, x: "y")
end

defmodule Surgex.RPC.ClientTest do
  use ExUnit.Case, async: false
  import Mock
  alias Mix.Config

  alias Surgex.RPC.{
    CallError,
    SampleClient,
    TransportError
  }

  alias Surgex.RPC.SampleClient.CreateUser
  alias Surgex.RPC.SampleClientWithCustomAdapter

  describe "call/1" do
    test "success" do
      request = %CreateUser.Request{
        user: %CreateUser.Request.User{
          name: "some guy",
          gender: :FEMALE
        }
      }

      assert {:ok, response} = SampleClient.call(request)

      assert response == %CreateUser.Response{
               user: %CreateUser.Response.User{
                 admin: false,
                 id: 1,
                 name: "some guy"
               }
             }
    end

    test "failure" do
      request = %CreateUser.Request{
        user: %CreateUser.Request.User{}
      }

      assert {:error, errors} = SampleClient.call(request)
      assert errors == [invalid: [struct: "user", struct: "gender"]]
    end

    test "transport error" do
      request = %CreateUser.Request{}

      assert_raise TransportError, "Mock failed with ** (RuntimeError) Sample mock failure", fn ->
        SampleClient.call(request)
      end
    end
  end

  describe "call!/1" do
    test "success with response" do
      request = %CreateUser.Request{
        user: %CreateUser.Request.User{
          name: "some guy",
          gender: :FEMALE
        }
      }

      assert SampleClient.call!(request) == %CreateUser.Response{
               user: %CreateUser.Response.User{
                 admin: false,
                 id: 1,
                 name: "some guy"
               }
             }
    end

    test "success with :ok" do
      request = %CreateUser.Request{
        user: %CreateUser.Request.User{
          name: "Jane",
          gender: :FEMALE
        }
      }

      assert SampleClient.call!(request) == %CreateUser.Response{}
    end

    test "failure (unnamed)" do
      request = %CreateUser.Request{
        user: %CreateUser.Request.User{
          name: "Bot"
        }
      }

      assert_raise CallError, ":error", fn ->
        SampleClient.call!(request)
      end
    end

    test "failure (atom)" do
      request = %CreateUser.Request{
        user: %CreateUser.Request.User{
          name: "John",
          permissions: [
            {"admin", false}
          ]
        }
      }

      assert_raise CallError, ":male_johns_forbidden", fn ->
        SampleClient.call!(request)
      end
    end

    test "failure (string)" do
      request = %CreateUser.Request{
        user: %CreateUser.Request.User{
          name: "John",
          permissions: [
            {"admin", true}
          ]
        }
      }

      assert_raise CallError, "male admins named John are forbidden", fn ->
        SampleClient.call!(request)
      end
    end

    test "failure (struct)" do
      request = %CreateUser.Request{
        user: %CreateUser.Request.User{}
      }

      assert_raise CallError, ":invalid (at [Access.key!(:user), Access.key!(:gender)])", fn ->
        SampleClient.call!(request)
      end
    end

    test "failure (repeated)" do
      request = %CreateUser.Request{
        user: %CreateUser.Request.User{
          photo_ids: [1, 2, 2]
        }
      }

      message =
        ":not_unique (at [Access.key!(:user), Access.key!(:photo_ids), Access.at(1)]), " <>
          ":not_unique (at [Access.key!(:user), Access.key!(:photo_ids), Access.at(2)])"

      assert_raise CallError, message, fn ->
        SampleClient.call!(request)
      end
    end

    test "failure (map)" do
      request = %CreateUser.Request{
        user: %CreateUser.Request.User{
          permissions: [
            {"admin", true}
          ]
        }
      }

      message =
        ":forbidden " <>
          "(at [Access.key!(:user), Access.key!(:permissions), Access.key!(\"admin\")])"

      assert_raise CallError, message, fn ->
        SampleClient.call!(request)
      end
    end

    test "transport error" do
      request = %CreateUser.Request{}

      assert_raise TransportError, "Mock failed with ** (RuntimeError) Sample mock failure", fn ->
        SampleClient.call!(request)
      end
    end

    test "custom adapter error with proto macro" do
      Config.persist(
        surgex: [
          rpc_mocking_enabled: false
        ]
      )

      request = %SampleClientWithCustomAdapter.Empty.Request{}

      assert_raise RuntimeError, "Dummy adapter (opts: [x: \"y\"])", fn ->
        SampleClientWithCustomAdapter.call!(request)
      end
    after
      Config.persist(
        surgex: [
          rpc_mocking_enabled: true
        ]
      )
    end

    test "custom adapter error with service macro" do
      Config.persist(
        surgex: [
          rpc_mocking_enabled: false
        ]
      )

      request = %SampleClientWithCustomAdapter.EmptyService.Request{}

      assert_raise RuntimeError, "Dummy adapter (opts: [x: \"y\"])", fn ->
        SampleClientWithCustomAdapter.call!(request)
      end
    after
      Config.persist(
        surgex: [
          rpc_mocking_enabled: true
        ]
      )
    end

    test "HTTP adapter success" do
      Config.persist(
        surgex: [
          rpc_mocking_enabled: false
        ]
      )

      mocked_post = fn _, _, _ ->
        response_payload = %{
          "errors" => [
            %{
              "reason" => ":some_code",
              "pointer" => [["struct", "user"], ["repeated", 0], ["map", "param"]]
            },
            %{
              "reason" => "some error"
            }
          ]
        }

        response_body = Poison.encode!(response_payload)

        %{
          status_code: 200,
          body: response_body
        }
      end

      request = %CreateUser.Request{}

      with_mock HTTPoison, post!: mocked_post do
        response = SampleClient.call(request)

        assert response == {
                 :error,
                 [
                   {:some_code, [struct: "user", repeated: 0, map: "param"]},
                   {"some error", nil}
                 ]
               }
      end
    after
      Config.persist(
        surgex: [
          rpc_mocking_enabled: true
        ]
      )
    end

    test "HTTP adapter error" do
      Config.persist(
        surgex: [
          rpc_mocking_enabled: false
        ]
      )

      request = %CreateUser.Request{}

      assert_raise TransportError, "HTTP request failed with code 404", fn ->
        SampleClient.call!(request)
      end
    after
      Config.persist(
        surgex: [
          rpc_mocking_enabled: true
        ]
      )
    end
  end
end
