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

  alias __MODULE__.{
    Error,
    Set,

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

    CastAllInProcessor,
    CastInProcessor,
    CastProcessor,
    DropInvalidProcessor,
    DropProcessor,
    ParseProcessor,
    RenameProcessor,
    ValidateAllProcessor,
    ValidateProcessor,
  }

  def add_error(set = %Set{}, key, error) do
    update_in set.errors, fn errors -> [{key, Error.build(error)} | errors] end
  end

  def cast(input, input_keys) do
    CastProcessor.call(input, input_keys)
  end

  def cast_all_in(input, input_keys, output_key, proc) do
    CastAllInProcessor.call(input, input_keys, proc, output_key)
  end

  def cast_in(input, input_key, output_key \\ nil, proc) do
    CastInProcessor.call(input, input_key, proc, output_key)
  end

  def drop(set, key) do
    DropProcessor.call(set, key)
  end

  def drop_invalid(set) do
    DropInvalidProcessor.call(set)
  end

  def get_input_key(%Set{mapping: mapping}, output_key) do
    Keyword.fetch!(mapping, output_key)
  end

  def parse(set, key, parser, opts \\ []) do
    ParseProcessor.call(set, key, parser, opts)
  end

  def parse_boolean(set, key) do
    parse(set, key, BooleanParser)
  end

  def parse_date(set, key) do
    parse(set, key, DateParser)
  end

  def parse_enum(set, key, allowed_values) do
    parse(set, key, EnumParser, allowed_values)
  end

  def parse_integer(set, key) do
    parse(set, key, IntegerParser)
  end

  def rename(set, old_key, new_key) do
    RenameProcessor.call(set, old_key, new_key)
  end

  def validate(set, key, validator, opts \\ []) do
    ValidateProcessor.call(set, key, validator, opts)
  end

  def validate_acceptance(set, key) do
    validate(set, key, AcceptanceValidator)
  end

  def validate_boolean(set, key) do
    validate(set, key, BooleanValidator)
  end

  def validate_all(set, validator, opts \\ []) do
    ValidateAllProcessor.call(set, validator, opts)
  end

  def validate_exclusion(set, key, forbidden_values) do
    validate(set, key, ExclusionValidator, forbidden_values)
  end

  def validate_format(set, key, format) do
    validate(set, key, FormatValidator, format)
  end

  def validate_inclusion(set, key, allowed_values) do
    validate(set, key, InclusionValidator, allowed_values)
  end

  def validate_length(set, key, opts) do
    validate(set, key, LengthValidator, opts)
  end

  def validate_number(set, key, opts \\ []) do
    validate(set, key, NumberValidator, opts)
  end

  def validate_required(set, key) do
    validate_all(set, RequiredValidator, key)
  end
end
