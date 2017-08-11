defmodule Surgex.RPC.CallError do
  @moduledoc """
  Describes an unexpected RPC call rejection.
  """

  defexception [:errors]

  def message(%__MODULE__{errors: errors}) do
    inspect errors
  end
end
