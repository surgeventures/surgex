defmodule Surgex.Parser.StringParser do
  @moduledoc """
  Available options:
  - **trim** is trimming whitespaces from the string, takes priority over min and max options
  - **min** is a minimal length of the string, returns :too_short error symbol
  - **max** is a maximal length of the string, returns :too_long error symbol
  """
  @type errors :: :too_short | :too_long
  @opts [:trim, :min, :max]

  @spec call(nil, any) :: {:ok, nil}
  @spec call(String.t(), list) :: {:ok, String.t()} | {:error, errors}
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

  defp nullify_empty_output(input = %{value: ""}), do: %{input | value: nil}
  defp nullify_empty_output(input), do: input
end
