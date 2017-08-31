defmodule Surgex.Parseus.KeyDropProcessor do
  @moduledoc false

  alias Surgex.Parseus

  def call(px = %Parseus{output: output}, key) do
    new_result = Keyword.delete(output, key)

    %{px | output: new_result}
  end
end
