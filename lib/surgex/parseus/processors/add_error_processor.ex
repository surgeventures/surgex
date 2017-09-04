defmodule Surgex.Parseus.AddErrorProcessor do
  alias Surgex.Parseus.{
    Error,
    Set,
  }

  def call(set = %Set{}, key, error) do
    update_in set.errors, fn errors -> [{key, Error.build(error)} | errors] end
  end
end
