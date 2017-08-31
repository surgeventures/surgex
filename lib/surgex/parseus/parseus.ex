defmodule Surgex.Parseus do
  @moduledoc """
  Legendary Elixir parser to tame all your input enumerables for good.

  ## Usage

  Here's a basic usage:

      input = %{
        "name" => "Mike",
        "email" => "mike@example.com"
        "age" => "21",
        "license-agreement" => "1",
        "notes" => "Please don't send me e-mails!",
      }

      import Surgex.Parseus

      %{output: output, errors: []} =
        input
        |> cast(["name", "email", "license-agreement", "age", "notes"])
        |> validate_required([:name, :email, :license_agreement])
        |> validate_format(:email, ~r/^.*@example\\.com$/)
        |> parse_boolean(:lincense_agreement)
        |> validate_equal(:license_agreement, true)
        |> drop_key(:license_agreement)
        |> parse_integer(:age)

      IO.inspect(output)
      # [full_name: "Mike", email: "mike@example.com", age: 21, notes: "..."]

  ## Details

  ### Parsing key(s)

  Key parsers get invoked via all `parse_*` built-in parsing functions which ultimately call generic
  `parse/4` (which can also be invoked with user-defined parsers).

  Here's how they work:

  - if there's no specific key in the input, the parser will not execute

  - if there's already an error associated with the key, the parser will not execute

  - otherwise the parser gets called with the current value of the key

  - if parser succeeds, the output value associated with the key gets updated

  - if parser fails, the key gets removed from the output and appropriate error gets added

  This basically means that if you pipe multiple parsers on the same key, they'll all get executed
  in a sequence with the output from previous parser getting passed to the next one, until the first
  parser failure, in which case subsequent parsers will not be called at all. In case of failure,
  the input value is no longer considered usable as an output and gets removed from it.

  ### Validating key(s)

  Key validators get invoked via all `validate_*` built-in validation functions which ultimately
  call  generic `validate/4` (which can also be invoked with user-defined validators).

  Here's how they work:

  - if there's no specific key in the input, the parser will not execute

  - otherwise the validator gets called with the current value of the key

  - if validator succeeds, nothing happens

  - if validator fails, an appropriate error gets added

  Key validators are a bit similar to key parsers, but they don't change the output (because they're
  not meant for that) and they still get called if there's already an error associated with the key
  (because we want to have as many errors as possible).

  > Note that there's still a way to avoid calling the specific validator upon some previous failed
  > assertion - this is where the parser's property of removing failed keys comes to use. You can
  > just call the parser before the validator and if parser fails, the validator won't get called.

  ### Validating multiple keys

  Global validators get invoked via the generic `validate_all/3` which can be invoked with
  user-defined validators.

  Here's how they work:

  - the validator gets called with the set of current values

  - if validator succeeds, nothing happens

  - if validator fails, an appropriate error or set of errors gets added

  As opposed to key validators, global validators get the whole set of current values as its input
  instead of a value of a single key. This allows them to implement a cross-key logical validation.
  They're also called regardless of which keys are filled in the input.

  """

  defstruct input: nil,
            output: [],
            errors: [],
            mapping: []

  alias __MODULE__.{
    Error,

    BooleanParser,
    DateParser,
    EnumParser,
    IntegerParser,

    AcceptanceValidator,
    BooleanValidator,
    ExclusionValidator,
    FormatValidator,
    InclusionValidator,
    LengthValidator,
    NumberValidator,
    RequiredValidator,

    CastProcessor,
    KeyDropProcessor,
    KeyParserProcessor,
    KeyRenameProcessor,
    KeyValidationProcessor,
    ValidationProcessor,
  }

  def cast(input, fields) do
    CastProcessor.call(input, fields)
  end

  def drop_key(px, key) do
    KeyDropProcessor.call(px, key)
  end

  def rename_key(px, old_key, new_key) do
    KeyRenameProcessor.call(px, old_key, new_key)
  end

  def parse(px, key, parser, opts \\ []) do
    KeyParserProcessor.call(px, key, parser, opts)
  end

  def parse_boolean(px, key) do
    parse(px, key, BooleanParser)
  end

  def parse_date(px, key) do
    parse(px, key, DateParser)
  end

  def parse_enum(px, key, allowed_values) do
    parse(px, key, EnumParser, allowed_values)
  end

  def parse_integer(px, key) do
    parse(px, key, IntegerParser)
  end

  def validate(px, key, validator, opts \\ []) do
    KeyValidationProcessor.call(px, key, validator, opts)
  end

  def validate_acceptance(px, key) do
    validate(px, key, AcceptanceValidator)
  end

  def validate_boolean(px, key) do
    validate(px, key, BooleanValidator)
  end

  def validate_all(px, validator, opts \\ []) do
    ValidationProcessor.call(px, validator, opts)
  end

  def validate_exclusion(px, key, forbidden_values) do
    validate(px, key, ExclusionValidator, forbidden_values)
  end

  def validate_format(px, key, format) do
    validate(px, key, FormatValidator, format)
  end

  def validate_inclusion(px, key, allowed_values) do
    validate(px, key, InclusionValidator, allowed_values)
  end

  def validate_length(px, key, opts) do
    validate(px, key, LengthValidator, opts)
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
