defmodule Surgex.ParseusExtras do
  @moduledoc """
  Extends Parseus with additional domain or tech stack specific helpers.
  """

  import Surgex.Parseus
  alias __MODULE__.{
    EmailValidator,
    IdValidator,
    IdListValidator,
    PageValidator,
  }

  def validate_email(set, key_or_keys) do
    validate(set, key_or_keys, EmailValidator)
  end

  def validate_id(set, key_or_keys) do
    validate(set, key_or_keys, IdValidator)
  end

  def validate_id_list(set, key_or_keys) do
    validate(set, key_or_keys, IdListValidator)
  end

  def validate_page(set, key_or_keys) do
    validate(set, key_or_keys, PageValidator)
  end
end
