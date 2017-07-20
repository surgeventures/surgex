defmodule Surgex.DeviseSession.Helpers do
  alias Plug.Conn

  def get_user_id(conn, scope \\ :user) do
    case Conn.get_session(conn, "warden.user.#{scope}.key") do
      [[id], _] when is_integer(id) ->
        id
      [_, [id], _] when is_integer(id) ->
        id
      _ ->
        nil
    end
  end
end
