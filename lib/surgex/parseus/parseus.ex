defmodule Surgex.Parseus do
  defstruct input: nil,
            output: [],
            errors: [],
            mapping: []

  alias __MODULE__.{
    Error,

    IntegerParser,

    NumberValidator,
    RequiredValidator,

    CastProcessor,
    KeyParserProcessor,
    KeyRenameProcessor,
    KeyValidationProcessor,
    ValidationProcessor,
  }

  def cast(input, fields) do
    CastProcessor.call(input, fields)
  end

  def rename_key(px, old_key, new_key) do
    KeyRenameProcessor.call(px, old_key, new_key)
  end

  def parse(px, key, parser, opts \\ []) do
    KeyParserProcessor.call(px, key, parser, opts)
  end

  def parse_integer(px, key) do
    parse(px, key, IntegerParser)
  end

  def validate(px, key, validator, opts \\ []) do
    KeyValidationProcessor.call(px, key, validator, opts)
  end

  def validate_all(px, validator, opts \\ []) do
    ValidationProcessor.call(px, validator, opts)
  end

  def validate_number(px, key, opts \\ []) do
    validate(px, key, NumberValidator, opts)
  end

  def validate_required(px, key) do
    validate_all(px, RequiredValidator, key)
  end

  def add_error(px = %__MODULE__{}, key, error = %Error{}) do
    update_in px.errors, fn errors -> [{key, error} | errors] end
  end

  def get_input_field(%__MODULE__{mapping: mapping}, key) do
    Keyword.fetch!(mapping, key)
  end
end
