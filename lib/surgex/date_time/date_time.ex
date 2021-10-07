if Code.ensure_loaded?(Timex) do
  defmodule Surgex.DateTime do
    @moduledoc """
    Utilities for creating date times.
    """

    @doc """
    Create UTC or time-zone date time given a date and seconds (from midnight) offset.

    ## Examples
      iex> Surgex.DateTime.date_and_offset_to_datetime(~D{2021-10-07}, 5400)
      ~U[2021-10-07 01:30:00Z]

      iex> Surgex.DateTime.date_and_offset_to_datetime(~D{2021-10-07}, 3600, "Europe/Warsaw")
      #DateTime<2021-10-07 01:00:00+02:00 CEST Europe/Warsaw>
    """
    @spec date_and_offset_to_datetime(Date.t(), integer, String.t()) :: DateTime.t()
    def date_and_offset_to_datetime(date, seconds_since_midnight, time_zone \\ "Etc/UTC") do
      date
      |> NaiveDateTime.new!(~T[00:00:00])
      |> Timex.shift(seconds: seconds_since_midnight)
      |> Timex.to_datetime(time_zone)
      |> case do
        {:error, {:could_not_resolve_timezone, _timezone, _, :wall}} ->
          date
          |> Timex.to_datetime(time_zone)
          |> Timex.shift(seconds: seconds_since_midnight)

        datetime ->
          disambiguate(datetime)
      end
    end

    defp disambiguate(time = %Timex.AmbiguousDateTime{}), do: time.after
    defp disambiguate(time = %DateTime{}), do: time
  end
end
