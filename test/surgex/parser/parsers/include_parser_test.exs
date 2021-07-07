defmodule Surgex.Parser.IncludeParserTest do
  use ExUnit.Case
  alias Surgex.Parser.IncludeParser

  describe "call/2" do
    test "nil" do
      assert IncludeParser.call(nil, [:user]) == {:ok, []}
    end

    test "valid input" do
      assert IncludeParser.call("", [:user]) == {:ok, []}
      assert IncludeParser.call("user", [:user]) == {:ok, [:user]}
      assert IncludeParser.call("user", [:user, :"user.ledger-account"]) == {:ok, [:user]}
      assert IncludeParser.call("user", ["user", "user.ledger-account"]) == {:ok, [:user]}

      assert IncludeParser.call("user,user.ledger-account", [:user, :"user.ledger-account"]) ==
               {:ok, [:user, :"user.ledger-account"]}

      assert IncludeParser.call("user,user.ledger-account", ["user", "user.ledger-account"]) ==
               {:ok, [:user, :"user.ledger-account"]}
    end

    test "invalid input" do
      assert IncludeParser.call("other", [:user]) == {:error, :invalid_relationship_path}

      assert IncludeParser.call("other,user.ledger-account", [:user, :"user.ledger-account"]) ==
               {:error, :invalid_relationship_path}
    end

    test "unsupported input type" do
      assert IncludeParser.call(0.3, [:user]) == {:error, :invalid_input}
    end
  end

  describe "flatten/2" do
    test "valid input" do
      assert IncludeParser.flatten({:ok, include: [:user]}, :include) == {:ok, include_user: true}
    end

    test "invalid input" do
      assert IncludeParser.flatten({:error, :test}, :sort) == {:error, :test}
      assert IncludeParser.flatten({:error, :test, nil}, :sort) == {:error, :test, nil}
    end
  end
end
