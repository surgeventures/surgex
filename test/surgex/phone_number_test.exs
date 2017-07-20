defmodule Surgex.PhoneNumberTest do
  use ExUnit.Case
  alias Surgex.PhoneNumber

  @phone_number_string_formatted "+48 600 700 800"
  @phone_number_string_formatted_alt "+048 600-700-800"
  @phone_number_string_e164 "48600700800"
  @phone_number_e164 48_600_700_800
  @phone_number %PhoneNumber{e164: @phone_number_e164}

  @phone_number_string_with_invalid_delimiter "+48 600/700-800"
  @phone_number_string_with_invalid_digits "+48 100-000-000"
  @phone_number_with_no_data %PhoneNumber{e164: nil}
  @phone_number_with_invalid_type %PhoneNumber{e164: @phone_number_string_e164}
  @phone_number_with_invalid_digits %PhoneNumber{e164: 48_100_000_000}

  describe "Inspect.inspect/2" do
    test "inspects valid phone numbers" do
      assert inspect(@phone_number) == "#Surgex.PhoneNumber<#{@phone_number_e164}>"
    end

    test "inspects invalid phone numbers" do
      assert inspect(@phone_number_with_invalid_type) ==
        "#Surgex.PhoneNumber<#{@phone_number_string_e164}>"
      assert inspect(@phone_number_with_invalid_digits) ==
        "#Surgex.PhoneNumber<48100000000>"
    end
  end

  describe "String.Chars.to_string/1" do
    test "interpolates valid phone number in strings" do
      assert "Phone: #{@phone_number}" == "Phone: #{@phone_number_string_formatted}"
    end

    test "interpolates invalid phone numbers in valid structs in strings" do
      assert "Phone: #{@phone_number_with_invalid_digits}" == "Phone: +48 10 000 00 00"
    end

    test "interpolates invalid phone number struct in strings" do
      assert "Phone: #{@phone_number_with_no_data}" == "Phone: "
      assert "Phone: #{@phone_number_with_invalid_type}" == "Phone: 48600700800"
    end
  end

  describe "type/0" do
    test "returns proper type" do
      assert PhoneNumber.type() == :string
    end
  end

  describe "cast/1" do
    test "casts itself" do
      assert PhoneNumber.cast(@phone_number) == {:ok, @phone_number}
    end

    test "casts valid strings" do
      assert PhoneNumber.cast(@phone_number_string_formatted) == {:ok, @phone_number}
      assert PhoneNumber.cast(@phone_number_string_formatted_alt) == {:ok, @phone_number}
      assert PhoneNumber.cast(@phone_number_string_e164) == {:ok, @phone_number}
    end

    test "casts invalid strings" do
      assert PhoneNumber.cast(@phone_number_string_with_invalid_delimiter) == :error
      assert PhoneNumber.cast(@phone_number_string_with_invalid_digits) == :error
    end
  end

  describe "load/1" do
    test "loads valid string" do
      assert PhoneNumber.load(@phone_number_string_e164) == {:ok, @phone_number}
    end

    test "loads invalid string" do
      assert PhoneNumber.load(@phone_number_string_formatted) == :error
    end
  end

  describe "dump/1" do
    test "dumps valid phone numbers" do
      assert PhoneNumber.dump(@phone_number) == {:ok, @phone_number_string_e164}
    end

    test "dumps invalid phone numbers in valid struct" do
      assert PhoneNumber.dump(@phone_number) == {:ok, @phone_number_string_e164}
      assert PhoneNumber.dump(@phone_number_with_invalid_digits) == {:ok, "48100000000"}
    end

    test "dumps invalid phone number structs" do
      assert PhoneNumber.dump(@phone_number_with_no_data) == :error
      assert PhoneNumber.dump(@phone_number_with_invalid_type) == :error
    end
  end

  describe "format/1" do
    test "formats valid phone numbers" do
      assert PhoneNumber.format(@phone_number) == @phone_number_string_formatted
    end

    test "formats invalid numbers in valid struct" do
      assert PhoneNumber.format(@phone_number_with_invalid_digits) == "+48 10 000 00 00"
    end

    test "raises on invalid phone number structs" do
      assert_raise(ArgumentError, fn ->
        PhoneNumber.format(@phone_number_with_no_data)
      end)

      assert_raise(ArgumentError, fn ->
        PhoneNumber.format(@phone_number_with_invalid_type)
      end)
    end
  end
end
