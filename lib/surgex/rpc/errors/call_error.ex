defmodule Surgex.RPC.CallError do
  defexception [:errors]

  def message(%__MODULE__{errors: errors}) do
    inspect errors
  end
end
