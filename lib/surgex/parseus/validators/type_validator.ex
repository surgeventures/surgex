defmodule Surgex.Parseus.TypeValidator do
  @moduledoc false

  def call(input, type) when not(is_list(type)), do: call(input, [type])
  def call(input, types) do
    case Enum.find(types, &type?(input, &1)) do
      nil -> :error
      _ -> :ok
    end
  end

  defp type?(input, type) when is_atom(type) do
    case Atom.to_string(type) do
      "Elixir." <> _ ->
        struct_type?(input, type)
      _ ->
        apply(Kernel, :"is_#{type}", [input])
    end
  end

  defp struct_type?(input, type) do
    case input do
      %{__struct__: ^type} -> true
      _ -> false
    end
  end
end
