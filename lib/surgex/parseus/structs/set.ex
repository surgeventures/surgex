defmodule Surgex.Parseus.Set do
  @moduledoc """
  Holds the input data along with output and errors that resulted from processing it.
  """

  defstruct input: nil,
            output: [],
            errors: [],
            mapping: []
end
