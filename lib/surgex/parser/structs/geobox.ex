defmodule Surgex.Parser.Geobox do
  @moduledoc """
  Holds a box made of two points on Earth's surface.
  """
  alias Surgex.Parser.Geolocation

  @type t :: %__MODULE__{north_east: Geolocation.t(), south_west: Geolocation.t()}

  defstruct [:north_east, :south_west]
end
