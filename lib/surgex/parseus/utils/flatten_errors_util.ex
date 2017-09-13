defmodule Surgex.Parseus.FlattenErrorsUtil do
  alias Surgex.Parseus.{Error, Set}

  def call(%Set{errors: errors}) do
    dig_errors(errors, [], [])
  end

  defp dig_errors(errors, initial_result, prefix) do
    {result, _} = Enum.reduce(errors, {initial_result, prefix}, &dig_error/2)
    result
  end
  defp dig_error(error_tuple, {result, prefix}) do
    case error_tuple do
      {key, error = %Error{}} ->
        {[{prefix ++ [key], error} | result], prefix}
      {key, errors} when is_list(errors) ->
        {dig_errors(errors, result, prefix ++ [key]), prefix}
      {key, errors} when is_map(errors) ->
        {dig_list_errors(errors, result, prefix ++ [key]), prefix}
    end
  end

  defp dig_list_errors(errors, initial_result, prefix) do
    {result, _} = Enum.reduce(errors, {initial_result, prefix}, &dig_list_error/2)
    result
  end
  defp dig_list_error({index, errors}, {result, prefix}) do
    {dig_errors(errors, result, prefix ++ [{:at, index}]), prefix}
  end
end
