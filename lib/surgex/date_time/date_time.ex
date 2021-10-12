if Code.ensure_loaded?(Timex) do
  defmodule Surgex.DateTime do
    @moduledoc """
    Utilities for creating date times.
    """

    @doc """
    Create UTC or time-zone date time given a date and seconds (from midnight) offset.

    ## Examples
      iex> Surgex.DateTime.date_and_offset_to_datetime(~D{2021-10-07}, 5400)
      {:ok, ~U[2021-10-07 01:30:00Z]}
    """
    @spec date_and_offset_to_datetime(Date.t(), integer(), String.t()) ::
            {:ok, DateTime.t()} | {:error, term()}
    def date_and_offset_to_datetime(date, seconds_since_midnight, timezone \\ "Etc/UTC") do
      with {:ok, datetime} <- NaiveDateTime.new(date, ~T[00:00:00]),
           {:ok, datetime} <- shift_datetime(datetime, seconds_since_midnight),
           {:ok, datetime} <- apply_timezone(datetime, timezone) do
        {:ok, datetime}
      else
        {:error, reason} -> {:error, reason}
      end
    end

    defp shift_datetime(datetime, offset) do
      case Timex.shift(datetime, seconds: offset) do
        %NaiveDateTime{} = datetime -> {:ok, datetime}
        {:error, reason} -> {:error, reason}
      end
    end

    defp apply_timezone(datetime, timezone) do
      case Timex.to_datetime(datetime, timezone) do
        %DateTime{} = datetime_in_timezone ->
          {:ok, datetime_in_timezone}

        %Timex.AmbiguousDateTime{} = datetime ->
          {:ok, datetime.after}

        {:error, reason} ->
          {:error, reason}
      end
    end
  end
end
