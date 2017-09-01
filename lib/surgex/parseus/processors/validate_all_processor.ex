defmodule Surgex.Parseus.ValidateAllProcessor do
  @moduledoc false

  alias Surgex.Parseus
  alias Surgex.Parseus.Error

  def call(px = %Parseus{output: output}, validator, opts) do
    validator
    |> call_validator(output, opts)
    |> handle_result(px, validator)
  end

  defp call_validator(validator, value, []), do: call_validator_with_args(validator, [value])
  defp call_validator(validator, value, opts), do: call_validator_with_args(validator, [value, opts])

  defp call_validator_with_args(validator, args) when is_atom(validator), do: apply(validator, :call, args)
  defp call_validator_with_args(validator, args) when is_function(validator), do: apply(validator, args)

  defp handle_result(:ok, px, _) do
    px
  end
  defp handle_result({:error, errors}, px, validator) when is_list(errors) do
    Enum.reduce(errors, px, fn
      {key, reason}, px ->
        put_error(px, key, source: validator, reason: reason)
      {key, reason, info}, px ->
        put_error(px, key, source: validator, reason: reason, info: info)
    end)
  end
  defp handle_result(:error, px, validator) do
    put_error(px, nil, source: validator)
  end
  defp handle_result({:error, key, reason}, px, validator) do
    put_error(px, key, source: validator, reason: reason)
  end
  defp handle_result({:error, key, reason, info}, px, validator) do
    put_error(px, key, source: validator, reason: reason, info: info)
  end

  defp put_error(px = %Parseus{errors: errors}, key, attrs) do
    new_error = Error.build(attrs)
    new_errors = [{key, new_error} | errors]

    %{px | errors: new_errors}
  end
end
