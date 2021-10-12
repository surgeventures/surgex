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
    @spec date_and_offset_to_datetime(Date.t(), integer(), String.t()) ::
            DateTime.t() | {:error, term()}
    def date_and_offset_to_datetime(date, seconds_since_midnight, timezone \\ "Etc/UTC") do
      date
      |> NaiveDateTime.new!(~T[00:00:00])
      |> shift_datetime(seconds_since_midnight)
      |> apply_timezone(timezone)
    end

    defp shift_datetime(datetime, offset) do
      case Timex.shift(datetime, seconds: offset) do
        %NaiveDateTime{} = datetime -> datetime
        {:error, reason} -> {:error, reason}
      end
    end

    defp apply_timezone({:error, reason}, _timezone), do: {:error, reason}

    defp apply_timezone(datetime, timezone) do
      case Timex.to_datetime(datetime, timezone) do
        %DateTime{} = datetime_in_timezone ->
          datetime_in_timezone

        %Timex.AmbiguousDateTime{} = datetime ->
          datetime.after

        {:error, reason} ->
          {:error, reason}
      end
    end
  end
end
