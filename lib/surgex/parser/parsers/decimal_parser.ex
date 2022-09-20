if Code.ensure_loaded?(Decimal) do
  defmodule Surgex.Parser.DecimalParser do
    @moduledoc false

    @type errors :: :invalid_decimal | :out_of_range
    @type option :: {:min, integer()} | {:max, integer()}

    @spec call(term(), [option()]) :: {:ok, Decimal.t() | nil} | {:error, errors()}
    def call(input, opts \\ [])
    def call(nil, _opts), do: {:ok, nil}
    def call("", _opts), do: {:ok, nil}

    def call(input, opts) when is_binary(input) do
      case Decimal.parse(input) do
        :error -> {:error, :invalid_decimal}
        {:ok, decimal} -> validate_range(decimal, opts)
        {decimal, ""} -> validate_range(decimal, opts)
        {_decimal, _} -> {:error, :invalid_decimal}
      end
    end

    def call(input, opts) when is_integer(input) do
      case Decimal.new(input) do
        :error -> {:error, :invalid_decimal}
        decimal -> validate_range(decimal, opts)
      end
    end

    def call(_input, _opts) do
      {:error, :invalid_decimal}
    end

    defp validate_range(decimal, opts) do
      min = Keyword.get(opts, :min)
      max = Keyword.get(opts, :max)

      if (is_integer(min) and Decimal.lt?(decimal, min)) or
           (is_integer(max) and Decimal.gt?(decimal, max)) do
        {:error, :out_of_range}
      else
        {:ok, decimal}
      end
    end
  end
end
