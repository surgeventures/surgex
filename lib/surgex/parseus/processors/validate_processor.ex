defmodule Surgex.Parseus.ValidateProcessor do
  @moduledoc false

  alias Surgex.Parseus
  alias Surgex.Parseus.Error

  def call(px, keys, validator, opts) when is_list(keys) do
    Enum.reduce(keys, px, &call(&2, &1, validator, opts))
  end
  def call(px = %Parseus{output: output}, key, validator, opts) do
    with {:ok, old_value} <- Keyword.fetch(output, key) do
      validator
      |> call_validator(old_value, opts)
      |> handle_result(px, key, validator)
    else
      _ -> px
    end
  end

  defp call_validator(validator, value, []), do: call_validator_with_args(validator, [value])
  defp call_validator(validator, value, opts), do: call_validator_with_args(validator, [value, opts])

  defp call_validator_with_args(validator, args) when is_atom(validator), do: apply(validator, :call, args)
  defp call_validator_with_args(validator, args) when is_function(validator), do: apply(validator, args)

  defp handle_result(:ok, px, _, _) do
    px
  end
  defp handle_result(:error, px, key, validator) do
    put_error(px, key, source: validator)
  end
  defp handle_result({:error, reason}, px, key, validator) do
    put_error(px, key, source: validator, reason: reason)
  end
  defp handle_result({:error, reason, info}, px, key, validator) do
    put_error(px, key, source: validator, reason: reason, info: info)
  end

  defp put_error(px = %Parseus{errors: errors}, key, attrs) do
    new_error = Error.build(attrs)
    new_errors = [{key, new_error} | errors]

    %{px | errors: new_errors}
  end
end
