defmodule Surgex.Parseus.ValidateAllProcessor do
  @moduledoc false

  alias Surgex.Parseus.{
    CallUtil,
    Error,
    Set,
  }

  def call(set = %Set{output: output}, validator, opts) do
    validator
    |> CallUtil.call(output, opts)
    |> handle_result(set, validator)
  end

  defp handle_result(:ok, set, _) do
    set
  end
  defp handle_result({:error, errors}, set, validator) when is_list(errors) do
    Enum.reduce(errors, set, fn
      {key, reason}, set ->
        put_error(set, key, source: validator, reason: reason)
      {key, reason, info}, set ->
        put_error(set, key, source: validator, reason: reason, info: info)
    end)
  end
  defp handle_result(:error, set, validator) do
    put_error(set, nil, source: validator)
  end
  defp handle_result({:error, key, reason}, set, validator) do
    put_error(set, key, source: validator, reason: reason)
  end
  defp handle_result({:error, key, reason, info}, set, validator) do
    put_error(set, key, source: validator, reason: reason, info: info)
  end

  defp put_error(set = %Set{errors: errors}, key, attrs) do
    new_error = Error.build(attrs)
    new_errors = [{key, new_error} | errors]

    %{set | errors: new_errors}
  end
end
