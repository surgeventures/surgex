defmodule Surgex.Parseus.CallUtil do
  def call(callable, arg, opts \\ [])
  def call(callable, arg, []), do: call_with_args(callable, [arg])
  def call(callable, arg, opts), do: call_with_args(callable, [arg, opts])

  def call_with_args(mod, args) when is_atom(mod), do: apply(mod, :call, args)
  def call_with_args(func, args) when is_function(func), do: apply(func, args)
end
