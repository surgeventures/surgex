defmodule Surgex.Parseus do
  defstruct input: nil,
            result: [],
            errors: [],
            mapping: []

  alias __MODULE__.{
    CastProcessor,
    Error,
    KeyPresenceProcessor,
    KeyValueProcessor,
  }

  def cast(self = %__MODULE__{}, fields) do
    CastProcessor.call(self, fields)
  end
  def cast(input, fields) do
    self = %__MODULE__{
      input: input
    }

    cast(self, fields)
  end

  def rename_key(self = %__MODULE__{result: result, mapping: mapping}, old_key, new_key) do
    map_value = Keyword.fetch!(mapping, old_key)
    new_mapping =
      mapping
      |> Keyword.delete(old_key)
      |> Keyword.put(new_key, map_value)

    new_result = case Keyword.fetch(result, old_key) do
      {:ok, value} ->
        result
        |> Keyword.delete(old_key)
        |> Keyword.put(new_key, value)
      :error ->
        result
    end

    %{self | mapping: new_mapping, result: new_result}
  end

  def parse(self, key, parser, opts \\ []) do
    KeyValueProcessor.call(self, key, parser,
      proc_opts: opts,
      valid_only: true,
      mutable_result: true)
  end

  def parse_integer(self, key) do
    parse(self, key, Surgex.Parseus.IntegerParser)
  end

  def validate(self, key, validator, opts \\ []) do
    KeyValueProcessor.call(self, key, validator,
      proc_opts: opts,
      valid_only: false,
      mutable_result: false)
  end

  def validate_number(self, key, opts \\ []) do
    validate(self, key, Surgex.Parseus.NumberValidator, opts)
  end

  def validate_required(self, keys) do
    KeyPresenceProcessor.call(self, keys)
  end

  def add_error(self = %__MODULE__{}, error = %Error{}) do
    update_in self.errors, fn errors -> [error | errors] end
  end

  defp unmap_key(%__MODULE__{mapping: mapping}, key), do: Keyword.fetch!(mapping, key)
end
