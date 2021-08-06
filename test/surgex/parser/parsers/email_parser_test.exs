defmodule Surgex.Parser.EmailParserTest do
  use ExUnit.Case
  alias Surgex.Parser.EmailParser

  test "nil" do
    assert EmailParser.call(nil) == {:ok, nil}
  end

  test "empty string" do
    assert EmailParser.call("") == {:ok, nil}
  end

  test "valid input" do
    valid_emails = [
      "me@example.com",
      "example@superlongdomainloremipsumdolor.co.uk",
      "mailhost!username@example.org",
      "me+you@gmail.com",
      "other.email-with-hyphen@example.com",
      "\".John.Doe\"@example.com",
      "user%example.com@example.org"
    ]

    Enum.each(valid_emails, fn email ->
      assert EmailParser.call(email) == {:ok, email}
    end)
  end

  test "invalid input" do
    assert EmailParser.call("me") == {:error, :invalid_email}
    assert EmailParser.call("me@example") == {:error, :invalid_email}
    assert EmailParser.call("example.com") == {:error, :invalid_email}
    assert EmailParser.call("he llo@example.com") == {:error, :invalid_email}
    assert EmailParser.call("me@example@gmail.com") == {:error, :invalid_email}
  end

  test "unsupported input" do
    assert EmailParser.call(15) == {:error, :invalid_email}
    assert EmailParser.call(0.5) == {:error, :invalid_email}
    assert EmailParser.call(["me@example@gmail.com"]) == {:error, :invalid_email}
  end
end
