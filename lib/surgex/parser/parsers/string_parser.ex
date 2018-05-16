defmodule Surgex.Parser.StringParser do
  @moduledoc """
  Available options:
  - **trim** is trimming whitespaces from the string, takes priority over min and max options
  - **min** is a minimal length of the string, returns :too_short error symbol
  - **max** is a maximal length of the string, returns :too_long error symbol
  """


  @opts [:trim, :min, :max]

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

  def validate_opts!([]), do: :ok
  def validate_opts!(opts) do
    invalid_opts = Keyword.keys(opts) -- @opts
    if Enum.any?(invalid_opts) do
      raise ArgumentError, message: "opts: #{invalid_opts} are invalid for string parser"
    end
  end

  defp process_opts(%{opts: []} = input), do: input
  defp process_opts(input) do
    input
    |> trim()
    |> validate_min()
    |> validate_max()
  end

  def trim(%{opts: opts, value: value} = input) do
    trim_value = Keyword.get(opts, :trim)
    cond do
      is_nil(trim_value) -> input
      true -> %{input | value: String.trim(value)}
    end
  end

  def validate_min(%{opts: opts, value: value} = input) do
    min_value = Keyword.get(opts, :min)
    cond do
      is_nil(min_value) -> input
      String.length(value) >= min_value -> input
      true -> %{input | error: :too_short}
    end
  end

  def validate_max(%{opts: opts, value: value} = input) do
    max_value = Keyword.get(opts, :max)
    cond do
      is_nil(max_value) -> input
      String.length(value) <= max_value -> input
      true -> %{input | error: :too_long}
    end
  end

  defp nullify_empty_output(%{value: ""} = input), do: %{input | value: nil}
  defp nullify_empty_output(input), do: input
end
