defmodule Surgex.Parser.Geobox do
  @moduledoc """
  Holds a box made of two points on Earth's surface.
  """

  defstruct [:north_east, :south_west]
end
