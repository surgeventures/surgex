defmodule Surgex.Parseus.DropInvalidProcessor do
  @moduledoc false

  alias Surgex.Parseus.Set

  def call(set = %Set{output: output, errors: errors}) do
    error_keys = Keyword.keys(errors)
    new_output = Keyword.drop(output, error_keys)

    %{set | output: new_output}
  end
end
