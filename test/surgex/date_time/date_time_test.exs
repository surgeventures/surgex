defmodule Surgex.DateTimeTest do
  use ExUnit.Case, async: true
  doctest Surgex.DateTime

  @hour 3600

  describe "date_and_offset_to_datetime/3" do
    setup do
      %{date: ~D{2017-07-31}}
    end

    test "start of the day", %{date: date} do
      assert ~U[2017-07-31 00:00:00Z] == Surgex.DateTime.date_and_offset_to_datetime(date, 0)
    end

    test "end of the day", %{date: date} do
      assert ~U[2017-07-31 23:59:59Z] ==
               Surgex.DateTime.date_and_offset_to_datetime(date, 24 * @hour - 1)
    end

    test "next day", %{date: date} do
      assert ~U[2017-08-01 00:00:00Z] ==
               Surgex.DateTime.date_and_offset_to_datetime(date, 24 * @hour)
    end

    test "with offset and time zone set", %{date: date} do
      assert DateTime.new!(date, ~T[02:30:00], "Asia/Dubai") ==
               Surgex.DateTime.date_and_offset_to_datetime(
                 date,
                 round(2.5 * @hour),
                 "Asia/Dubai"
               )
    end

    test "returns error on invalid time zone" do
      assert {:error, :time_zone_not_found} ==
               Surgex.DateTime.date_and_offset_to_datetime(~D{2017-07-31}, 1 * @hour, "Moon/Crater")
    end

    test "return error on invalid offset" do
      assert {:error, {:unknown_shift_unit, :seconds}} ==
               Surgex.DateTime.date_and_offset_to_datetime(~D{2017-07-31}, "invalid offset")
    end

    test "raises exception on invalid date" do
      assert_raise ArgumentError, ~r/reason: :invalid_date/, fn ->
        Surgex.DateTime.date_and_offset_to_datetime(Date.new!(2000, 13, 1), 0)
      end
    end
  end

  describe "date_and_offset_to_datetime/3 on DST dates" do
    setup do
      %{
        dst_dates: [
          %{
            autumn_date: ~D{2021-10-31},
            spring_date: ~D{2022-03-27},
            time_zone: "Europe/London"
          },
          %{
            autumn_date: ~D{2021-11-07},
            spring_date: ~D{2022-03-13},
            time_zone: "America/New_York"
          },
          %{
            autumn_date: ~D{2022-04-03},
            spring_date: ~D{2021-10-03},
            time_zone: "Australia/Sydney"
          }
        ]
      }
    end

    test "start of the day", %{dst_dates: dates} do
      for %{autumn_date: autumn, spring_date: spring, time_zone: time_zone} <- dates do
        assert DateTime.new!(autumn, ~T[00:00:00], "Etc/UTC") ==
                 Surgex.DateTime.date_and_offset_to_datetime(autumn, 0)

        assert DateTime.new!(autumn, ~T[00:00:00], time_zone) ==
                 Surgex.DateTime.date_and_offset_to_datetime(autumn, 0, time_zone)

        assert DateTime.new!(spring, ~T[00:00:00], "Etc/UTC") ==
                 Surgex.DateTime.date_and_offset_to_datetime(spring, 0)

        assert DateTime.new!(spring, ~T[00:00:00], time_zone) ==
                 Surgex.DateTime.date_and_offset_to_datetime(spring, 0, time_zone)
      end
    end

    test "end of the day", %{dst_dates: dates} do
      for %{autumn_date: autumn, spring_date: spring, time_zone: time_zone} <- dates do
        assert DateTime.new!(autumn, ~T[23:59:59], "Etc/UTC") ==
                 Surgex.DateTime.date_and_offset_to_datetime(autumn, 24 * @hour - 1)

        assert DateTime.new!(autumn, ~T[23:59:59], time_zone) ==
                 Surgex.DateTime.date_and_offset_to_datetime(autumn, 24 * @hour - 1, time_zone)

        assert DateTime.new!(spring, ~T[23:59:59], "Etc/UTC") ==
                 Surgex.DateTime.date_and_offset_to_datetime(spring, 24 * @hour - 1)

        assert DateTime.new!(spring, ~T[23:59:59], time_zone) ==
                 Surgex.DateTime.date_and_offset_to_datetime(spring, 24 * @hour - 1, time_zone)
      end
    end

    test "next day", %{dst_dates: dates} do
      for %{autumn_date: autumn, spring_date: spring} <- dates do
        assert autumn |> Date.add(1) |> DateTime.new!(~T[00:00:00], "Etc/UTC") ==
                 Surgex.DateTime.date_and_offset_to_datetime(autumn, 24 * @hour)

        assert spring |> Date.add(1) |> DateTime.new!(~T[00:00:00], "Etc/UTC") ==
                 Surgex.DateTime.date_and_offset_to_datetime(spring, 24 * @hour)
      end
    end

    test "autumn date with offsets and time zone", %{dst_dates: dates} do
      for %{autumn_date: date, time_zone: time_zone} <- dates do
        assert DateTime.new!(date, ~T[08:00:00], time_zone) ==
                 Surgex.DateTime.date_and_offset_to_datetime(date, 8 * @hour, time_zone)
      end
    end

    test "spring date with offsets and time zone", %{dst_dates: dates} do
      for %{spring_date: date, time_zone: time_zone} <- dates do
        assert DateTime.new!(date, ~T[08:00:00], time_zone) ==
                 Surgex.DateTime.date_and_offset_to_datetime(date, 8 * @hour, time_zone)
      end
    end

    test "ambiguous autumn hour in London time zone", %{dst_dates: dates} do
      find_date_fn = fn date -> date.time_zone == "Europe/London" end
      %{autumn_date: date, time_zone: time_zone} = Enum.find(dates, &find_date_fn.(&1))

      assert %DateTime{
               day: 31,
               hour: 1,
               minute: 0,
               month: 10,
               second: 0,
               time_zone: ^time_zone,
               year: 2021
             } = Surgex.DateTime.date_and_offset_to_datetime(date, 1 * @hour, time_zone)
    end

    test "ambiguous autumn hour in Australia time zone", %{dst_dates: dates} do
      find_date_fn = fn date -> date.time_zone == "Australia/Sydney" end
      %{autumn_date: date, time_zone: time_zone} = Enum.find(dates, &find_date_fn.(&1))

      assert %DateTime{
               day: 3,
               hour: 1,
               minute: 0,
               month: 4,
               second: 0,
               time_zone: ^time_zone,
               year: 2022
             } = Surgex.DateTime.date_and_offset_to_datetime(date, 1 * @hour, time_zone)
    end

    test "error on non-existent ambiguous spring hour", %{dst_dates: dates} do
      find_date_fn = fn date -> date.time_zone == "Europe/London" end
      %{spring_date: date, time_zone: time_zone} = Enum.find(dates, &find_date_fn.(&1))

      assert {:error, {:could_not_resolve_timezone, ^time_zone, _seconds_from_zeroyear, :wall}} =
               Surgex.DateTime.date_and_offset_to_datetime(date, 1 * @hour, time_zone)
    end
  end
end
