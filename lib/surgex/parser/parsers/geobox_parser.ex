defmodule Surgex.Parser.GeoboxParser do
  @moduledoc false

  alias Surgex.Parser.{Geobox, GeolocationParser}

  def call(nil), do: {:ok, nil}
  def call(input) when is_binary(input) do
    with [lat_ne, lng_ne, lat_sw, lng_sw] <- String.split(input, ","),
         {:ok, ne} <- GeolocationParser.call({lat_ne, lng_ne}),
         {:ok, sw} <- GeolocationParser.call({lat_sw, lng_sw}),
         true <- valid_box?(ne, sw)
    do
      {:ok, %Geobox{north_east: ne, south_west: sw}}
    else
      split_result when is_list(split_result) -> {:error, :invalid_geobox_tuple}
      false -> {:error, :invalid_geobox}
      {:error, reason} -> {:error, reason}
    end
  end

  defp valid_box?(north_east, south_west) do
    north_east.latitude - south_west.latitude > 0
  end
end
