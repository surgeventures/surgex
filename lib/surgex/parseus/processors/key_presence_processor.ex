defmodule Surgex.Parseus.KeyPresenceProcessor do
  alias Surgex.Parseus
  alias Surgex.Parseus.Error

  def call(self, key) when is_atom(key), do: call(self, [key])
  def call(self = %Parseus{result: result, errors: errors}, keys) do
    new_errors = Enum.reduce(keys, errors, fn key, errors ->
      if Keyword.has_key?(result, key) do
        errors
      else
        [Error.build(reason: :required, key: key) | errors]
      end
    end)

    %{self | errors: new_errors}
  end
end
