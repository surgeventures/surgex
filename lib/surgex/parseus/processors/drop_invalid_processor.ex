defmodule Surgex.Parseus.DropInvalidProcessor do
  @moduledoc false

  alias Surgex.Parseus

  def call(px = %Parseus{output: output, errors: errors}) do
    error_keys = Keyword.keys(errors)
    new_output = Keyword.drop(output, error_keys)

    %{px | output: new_output}
  end
end
