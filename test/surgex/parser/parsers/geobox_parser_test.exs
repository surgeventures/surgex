defmodule Surgex.Parser.GeoboxParserTest do
  use ExUnit.Case
  alias Surgex.Parser.{Geobox, GeoboxParser, Geolocation}

  test "nil" do
    assert GeoboxParser.call(nil) == {:ok, nil}
  end

  test "valid input" do
    # northern hemisphere
    assert GeoboxParser.call("12.345,67.891,12.145,67.801") ==
      {:ok, %Geobox{
        north_east: %Geolocation{latitude: 12.345, longitude: 67.891},
        south_west: %Geolocation{latitude: 12.145, longitude: 67.801}
      }}

    # southern hemisphere
    assert GeoboxParser.call("-22.202,-17.710,-22.303,-17.891") ==
      {:ok, %Geobox{
        north_east: %Geolocation{latitude: -22.202, longitude: -17.71},
        south_west: %Geolocation{latitude: -22.303, longitude: -17.891}
      }}

    # 180 degrees eastern
    assert GeoboxParser.call("30.1,-179.85,29.9,179.95") ==
      {:ok, %Geobox{
        north_east: %Geolocation{latitude: 30.1, longitude: -179.85},
        south_west: %Geolocation{latitude: 29.9, longitude: 179.95}
      }}
  end

  test "invalid input" do
    assert GeoboxParser.call("12.345,67.891,12.445,67.701") == {:error, :invalid_geobox}
    assert GeoboxParser.call("-22.302,-17.891,-22.203,-17.910") == {:error, :invalid_geobox}
    assert GeoboxParser.call("12.345,67.891,12.445,267.701") == {:error, :invalid_geolocation}
    assert GeoboxParser.call("-22.302,-17.891,-22.203,?") == {:error, :invalid_float}
    assert GeoboxParser.call("-22.302,-17.891,-22.203") == {:error, :invalid_geobox_tuple}
    assert GeoboxParser.call("?") == {:error, :invalid_geobox_tuple}
  end
end
