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
    ordered_opts = set_opts_priority(opts)
    input
    |> process_opts(ordered_opts)
    |> nullify_empty_output()
  end

  def validate_opts!(nil), do: :ok
  def validate_opts!(opts) do
    invalid_opts = Keyword.keys(opts) -- @opts
    if Enum.any?(invalid_opts) do
      raise ArgumentError, message: "opts: #{opts} are invalid for string parser"
    end
  end

  defp set_opts_priority(opts) do
    Enum.sort(opts, &(get_order_index(&1) <= get_order_index(&2)))
  end

  defp get_order_index({key, _value}) do
    Enum.find_index(@opts, &(&1 == key))
  end

  defp process_opts(input, []), do: {:ok, input}
  defp process_opts(input, [{opt, value} | remaining]) do
    result = case opt do
      :trim -> trim(input)
      :min -> validate_min(input, value)
      :max -> validate_max(input, value)
    end
    case result do
      {:ok, output} -> process_opts(output, remaining)
      {:error, error_type} -> {:error, error_type}
    end
  end

  def trim(input), do: {:ok, String.trim(input)}

  def validate_min(input, value) do
    if String.length(input) >= value do
      {:ok, input}
    else
      {:error, :too_short}
    end
  end

  def validate_max(input, value) do
    if String.length(input) <= value do
      {:ok, input}
    else
      {:error, :too_long}
    end
  end

  defp nullify_empty_output({:ok, ""}), do: {:ok, nil}
  defp nullify_empty_output(output), do: output
end
