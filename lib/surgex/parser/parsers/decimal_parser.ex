if Code.ensure_loaded?(Decimal) do
  defmodule Surgex.Parser.DecimalParser do
    @moduledoc false

    @type errors :: :invalid_decimal | :out_of_range
    @type option :: {:min, integer()} | {:max, integer()}

    # Check Decimal version at compile time
    # Decimal < 2.0: parse/1 returns {:ok, decimal} | :error
    # Decimal >= 2.0: parse/1 returns {decimal, remainder} | :error
    @decimal_version :decimal |> Application.spec(:vsn) |> to_string() |> Version.parse!()
    @decimal_2_plus Version.compare(@decimal_version, Version.parse!("2.0.0")) in [:gt, :eq]

    @spec call(term(), [option()]) :: {:ok, Decimal.t() | nil} | {:error, errors()}
    def call(input, opts \\ [])
    def call(nil, _opts), do: {:ok, nil}
    def call("", _opts), do: {:ok, nil}

    if @decimal_2_plus do
      def call(input, opts) when is_binary(input) do
        # Decimal >= 2.0: parse/1 returns {decimal, remainder} | :error
        case Decimal.parse(input) do
          :error ->
            {:error, :invalid_decimal}

          {decimal, ""} ->
            validate_range(decimal, opts)

          {_decimal, _remainder} ->
            {:error, :invalid_decimal}
        end
      end
    else
      def call(input, opts) when is_binary(input) do
        # Decimal < 2.0: parse/1 returns {:ok, decimal} | :error
        case Decimal.parse(input) do
          :error ->
            {:error, :invalid_decimal}

          {:ok, decimal} ->
            validate_range(decimal, opts)
        end
      end
    end

    def call(input, opts) when is_integer(input) do
      decimal = Decimal.new(input)
      validate_range(decimal, opts)
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
