defmodule Surgex.Parser.Geolocation do
  @moduledoc """
  Holds a specific point on Earth's surface.
  """

  @type t :: %__MODULE__{latitude: number, longitude: number}

  defstruct [:latitude, :longitude]
end
