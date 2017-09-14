defmodule Surgex.ParseusExtras do
  @moduledoc """
  Extends Parseus with additional domain or tech stack specific helpers.
  """

  import Surgex.Parseus
  alias __MODULE__.{
    EmailValidator,
    IdParser,
    IdListParser,
    PageParser,
  }

  def parse_id(set, key_or_keys) do
    parse(set, key_or_keys, IdParser)
  end

  def parse_id_list(set, key_or_keys) do
    parse(set, key_or_keys, IdListParser)
  end

  def parse_page(set, key_or_keys) do
    parse(set, key_or_keys, PageParser)
  end

  def validate_email(set, key_or_keys) do
    validate(set, key_or_keys, EmailValidator)
  end
end
