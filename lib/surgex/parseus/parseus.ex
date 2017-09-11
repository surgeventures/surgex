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
    BlankStringToNilMapper,

    BooleanParser,
    DateParser,
    EnumParser,
    FloatParser,
    IntegerParser,

    AddErrorProcessor,
    CastAllInProcessor,
    CastInProcessor,
    CastProcessor,
    DropInvalidProcessor,
    DropNilProcessor,
    DropProcessor,
    FilterProcessor,
    JoinProcessor,
    MapProcessor,
    ParseProcessor,
    RenameProcessor,
    ValidateAllProcessor,
    ValidateProcessor,

    FlattenErrorsUtil,
    GetInputPathUtil,
    ResolveUtil,
    ResolveTupleUtil,

    AcceptanceValidator,
    BooleanValidator,
    ExclusionValidator,
    FormatValidator,
    InclusionValidator,
    LengthValidator,
    NumberValidator,
    RequiredValidator,
  }

  def add_error(set, key, error) do
    AddErrorProcessor.call(set, key, error)
  end

  def cast(input, input_key_or_keys) do
    CastProcessor.call(input, input_key_or_keys)
  end

  def cast_all_in(input, input_key_or_path, output_key, mod_or_func) do
    CastAllInProcessor.call(input, input_key_or_path, output_key, mod_or_func)
  end

  def cast_in(input, input_key_or_path, output_key \\ nil, mod_or_func) do
    CastInProcessor.call(input, input_key_or_path, output_key, mod_or_func)
  end

  def drop(set, key_or_keys) do
    DropProcessor.call(set, key_or_keys)
  end

  def drop_invalid(set, key_or_keys \\ nil) do
    DropInvalidProcessor.call(set, key_or_keys)
  end

  def drop_nil(set, key_or_keys \\ nil) do
    DropNilProcessor.call(set, key_or_keys)
  end

  def filter(set, key_or_keys, mod_or_func) do
    FilterProcessor.call(set, key_or_keys, mod_or_func)
  end

  def flatten_errors(set) do
    FlattenErrorsUtil.call(set)
  end

  def join(set, old_keys, new_key, opts \\ []) do
    JoinProcessor.call(set, old_keys, new_key, opts)
  end

  def get_input_path(set, output_key_or_path) do
    GetInputPathUtil.call(set, output_key_or_path)
  end

  def map(set, key_or_keys, mod_or_func) do
    MapProcessor.call(set, key_or_keys, mod_or_func)
  end

  def map_blank_string_to_nil(set, key_or_keys) do
    map(set, key_or_keys, BlankStringToNilMapper)
  end

  def parse(set, key_or_keys, mod_or_func, opts \\ []) do
    ParseProcessor.call(set, key_or_keys, mod_or_func, opts)
  end

  def parse_boolean(set, key_or_keys) do
    parse(set, key_or_keys, BooleanParser)
  end

  def parse_date(set, key_or_keys) do
    parse(set, key_or_keys, DateParser)
  end

  def parse_enum(set, key_or_keys, allowed_values) do
    parse(set, key_or_keys, EnumParser, allowed_values)
  end

  def parse_float(set, key_or_keys) do
    parse(set, key_or_keys, FloatParser)
  end

  def parse_integer(set, key_or_keys) do
    parse(set, key_or_keys, IntegerParser)
  end

  def rename(set, old_key, new_key) do
    RenameProcessor.call(set, old_key, new_key)
  end

  def resolve(set) do
    ResolveUtil.call(set)
  end

  def resolve_tuple(set, key_or_keys) do
    ResolveTupleUtil.call(set, key_or_keys)
  end

  def validate(set, key_or_keys, mod_or_func, opts \\ []) do
    ValidateProcessor.call(set, key_or_keys, mod_or_func, opts)
  end

  def validate_acceptance(set, key_or_keys) do
    validate(set, key_or_keys, AcceptanceValidator)
  end

  def validate_all(set, validator, opts \\ []) do
    ValidateAllProcessor.call(set, validator, opts)
  end

  def validate_boolean(set, key_or_keys) do
    validate(set, key_or_keys, BooleanValidator)
  end

  def validate_exclusion(set, key_or_keys, forbidden_values) do
    validate(set, key_or_keys, ExclusionValidator, forbidden_values)
  end

  def validate_format(set, key_or_keys, format) do
    validate(set, key_or_keys, FormatValidator, format)
  end

  def validate_inclusion(set, key_or_keys, allowed_values) do
    validate(set, key_or_keys, InclusionValidator, allowed_values)
  end

  def validate_length(set, key_or_keys, opts) do
    validate(set, key_or_keys, LengthValidator, opts)
  end

  def validate_number(set, key_or_keys, opts \\ []) do
    validate(set, key_or_keys, NumberValidator, opts)
  end

  def validate_required(set, key_or_keys) do
    validate_all(set, RequiredValidator, key_or_keys)
  end
end
