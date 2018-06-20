defmodule Surgex.RPC.SampleClient do
  @moduledoc false

  use Surgex.RPC.Client

  transport(:http, url: "http://example.com/rpc", secret: "xyz")

  proto(:create_user)
end

defmodule Surgex.RPC.SampleClient.CreateUserMock do
  @moduledoc false

  alias Surgex.RPC.SampleClient.CreateUser.{Request, Response}

  def call(%Request{user: %Request.User{name: "Jane", gender: :FEMALE}}) do
    :ok
  end

  def call(%Request{user: %Request.User{name: name, gender: :FEMALE}}) do
    response = %Response{
      user: %Response.User{
        id: 1,
        admin: false,
        name: name
      }
    }

    {:ok, response}
  end

  def call(%Request{user: %Request.User{name: "Bot"}}) do
    :error
  end

  def call(%Request{user: %Request.User{name: "John", permissions: [{"admin", true}]}}) do
    {:error, "male admins named John are forbidden"}
  end

  def call(%Request{user: %Request.User{name: "John", permissions: [{"admin", false}]}}) do
    {:error, :male_johns_forbidden}
  end

  def call(%Request{user: %Request.User{photo_ids: [1, 2, 2]}}) do
    {:error,
     not_unique: [struct: "user", struct: "photo_ids", repeated: 1],
     not_unique: [struct: "user", struct: "photo_ids", repeated: 2]}
  end

  def call(%Request{user: %Request.User{permissions: [{"admin", true}]}}) do
    {:error, forbidden: [struct: "user", struct: "permissions", map: "admin"]}
  end

  def call(%Request{user: %Request.User{}}) do
    {:error, invalid: [struct: "user", struct: "gender"]}
  end

  def call(_request) do
    raise "Sample mock failure"
  end
end
