defmodule Surgex.Parser.GeolocationParser do
  @moduledoc false

  alias Surgex.Parser.{FloatParser, Geolocation}

  @type errors :: :invalid_geolocation_tuple | :invalid_geolocation

  @spec call(nil) :: {:ok, nil}
  @spec call(String.t()) ::
          {:ok, Geolocation.t()} | {:error, errors} | {:error, FloatParser.errors()}
  @spec call({String.t(), String.t()}) ::
          {:ok, Geolocation.t()} | {:error, errors} | {:error, FloatParser.errors()}
  def call(nil), do: {:ok, nil}
  def call(""), do: {:ok, nil}

  def call(input) when is_binary(input) do
    case String.split(input, ",") do
      [lat_string, lng_string] ->
        parse_lat_lng_strings(lat_string, lng_string)

      _split_result ->
        {:error, :invalid_geolocation_tuple}
    end
  end

  def call({lat_string, lng_string}) when is_binary(lat_string) and is_binary(lng_string) do
    parse_lat_lng_strings(lat_string, lng_string)
  end

  defp parse_lat_lng_strings(lat_string, lng_string) do
    with {:ok, lat} <- FloatParser.call(lat_string),
         {:ok, lng} <- FloatParser.call(lng_string),
         true <- valid_location?(lat, lng) do
      {:ok, %Geolocation{latitude: lat, longitude: lng}}
    else
      false -> {:error, :invalid_geolocation}
      {:error, reason} -> {:error, reason}
    end
  end

  defp valid_location?(lat, _lng) when lat < -90, do: false
  defp valid_location?(lat, _lng) when lat > 90, do: false
  defp valid_location?(_lat, lng) when lng < -180, do: false
  defp valid_location?(_lat, lng) when lng > 180, do: false
  defp valid_location?(_lat, _lng), do: true
end
