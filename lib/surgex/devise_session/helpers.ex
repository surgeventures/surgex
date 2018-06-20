defmodule Surgex.DeviseSession.Helpers do
  @moduledoc """
  Helpers that assist in working with session fetched via `Surgex.DeviseSession` plug.
  """

  alias Plug.Conn

  @doc """
  Returns currently logged-in user's identifier, optionally in specified scope.
  """
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
