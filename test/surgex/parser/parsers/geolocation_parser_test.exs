defmodule Surgex.Parser.GeolocationParserTest do
  use ExUnit.Case
  alias Surgex.Parser.{Geolocation, GeolocationParser}

  test "nil" do
    assert GeolocationParser.call(nil) == {:ok, nil}
  end

  test "valid input" do
    assert GeolocationParser.call("12.345,67.891") ==
             {:ok, %Geolocation{latitude: 12.345, longitude: 67.891}}
  end

  test "invalid input" do
    assert GeolocationParser.call("12.445,267.701") == {:error, :invalid_geolocation}
    assert GeolocationParser.call("?") == {:error, :invalid_geolocation_tuple}
    assert GeolocationParser.call("-22.203,?") == {:error, :invalid_float}
  end

  test "unsupported input type" do
    assert GeolocationParser.call(1) == {:error, :invalid_geolocation_tuple}
    assert GeolocationParser.call(6.7) == {:error, :invalid_geolocation_tuple}
    assert GeolocationParser.call(["12.345,67.891"]) == {:error, :invalid_geolocation_tuple}
  end
end
