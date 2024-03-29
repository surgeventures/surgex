defmodule Surgex.Parser.StringParser do
  @moduledoc """
  Available options:
  - **trim** is trimming whitespaces from the string, takes priority over min and max options
  - **min** is a minimal length of the string, returns :too_short error symbol
  - **max** is a maximal length of the string, returns :too_long error symbol
  - **regex** - input string must match passed regular expression, this is done after trimming
  """
  @type errors :: :too_short | :too_long | :invalid_string | :bad_format
  @type option :: {:trim, boolean()} | {:min, integer()} | {:max, integer()} | {:regex, Regex.t()}
  @opts [:trim, :min, :max, :regex]

  @spec call(term(), [option()]) :: {:ok, String.t() | nil} | {:error, errors()}
  def call(input, opts \\ [])
  def call(nil, _opts), do: {:ok, nil}

  def call(input, opts) when is_binary(input) do
    validate_opts!(opts)

    output =
      %{value: input, error: nil, opts: opts}
      |> process_opts()
      |> nullify_empty_output()

    case output do
      %{value: output, error: nil} -> {:ok, output}
      %{error: error} -> {:error, error}
    end
  end

  def call(_input, _opts), do: {:error, :invalid_string}

  @spec validate_opts!(list) :: :ok
  defp validate_opts!([]), do: :ok

  defp validate_opts!(opts) do
    invalid_opts = Keyword.keys(opts) -- @opts

    if Enum.any?(invalid_opts) do
      raise ArgumentError, message: "opts: #{invalid_opts} are invalid for string parser"
    end
  end

  defp process_opts(input = %{opts: []}), do: input

  defp process_opts(input) do
    input
    |> trim()
    |> validate_min()
    |> validate_max()
    |> check_regex()
  end

  @spec trim(%{opts: list, value: String.t(), error: nil}) :: %{
          opts: list,
          value: String.t(),
          error: nil
        }
  def trim(input = %{opts: opts, value: value}) do
    trim_value = Keyword.get(opts, :trim)

    if is_nil(trim_value) do
      input
    else
      %{input | value: String.trim(value)}
    end
  end

  @spec validate_min(%{opts: list, value: String.t(), error: nil}) :: %{
          opts: list,
          value: String.t(),
          error: nil | :too_short
        }
  def validate_min(input = %{opts: opts, value: value}) do
    min_value = Keyword.get(opts, :min)

    cond do
      is_nil(min_value) -> input
      String.length(value) >= min_value -> input
      true -> %{input | error: :too_short}
    end
  end

  @spec validate_max(%{opts: list, value: String.t(), error: nil}) :: %{
          opts: list,
          value: String.t(),
          error: nil | :too_long
        }
  def validate_max(input = %{opts: opts, value: value}) do
    max_value = Keyword.get(opts, :max)

    cond do
      is_nil(max_value) -> input
      String.length(value) <= max_value -> input
      true -> %{input | error: :too_long}
    end
  end

  @spec check_regex(%{opts: list, value: String.t(), error: nil}) :: %{
          opts: list,
          value: String.t(),
          error: nil | :bad_format
        }
  def check_regex(input = %{opts: opts, value: value}) do
    regex = Keyword.get(opts, :regex)

    cond do
      is_nil(regex) -> input
      Regex.match?(regex, value) -> input
      true -> %{input | error: :bad_format}
    end
  end

  defp nullify_empty_output(input = %{value: ""}), do: %{input | value: nil}
  defp nullify_empty_output(input), do: input
end
