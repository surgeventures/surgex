defmodule Surgex.Parseus.KeyValueProcessor do
  alias Surgex.Parseus
  alias Surgex.Parseus.Error

  def call(self = %Parseus{result: result, errors: errors}, key, proc, opts) do
    proc_opts = Keyword.fetch!(opts, :proc_opts)
    valid_only = Keyword.fetch!(opts, :valid_only)
    mutable_result = Keyword.fetch!(opts, :mutable_result)

    validity_pass = not(valid_only) || not(Keyword.has_key?(errors, key))

    with true <- validity_pass,
         {:ok, old_value} <- Keyword.fetch(result, key)
    do
      proc
      |> call_proc(old_value, proc_opts)
      |> handle_result(self, mutable_result, key: key, proc: proc)
    else
      _ -> self
    end
  end

  defp call_proc(proc, value, []), do: call_proc_with_args(proc, [value])
  defp call_proc(proc, value, opts), do: call_proc_with_args(proc, [value, opts])

  defp call_proc_with_args(proc, args) when is_atom(proc), do: apply(proc, :call, args)
  defp call_proc_with_args(proc, args) when is_function(proc), do: apply(proc, args)

  defp handle_result(:ok, self = %Parseus{}, false, _context) do
    self
  end
  defp handle_result({:ok, new_value}, self = %Parseus{result: result}, true, context) do
    key = Keyword.fetch!(context, :key)
    new_result = Keyword.put(result, key, new_value)
    %{self | result: new_result}
  end
  defp handle_result(:error, self, _, context) do
    build_error([], self, context)
  end
  defp handle_result({:error, reason}, self, _, context) do
    build_error([reason: reason], self, context)
  end
  defp handle_result({:error, reason, info}, self, _, context) do
    build_error([reason: reason, info: info], self, context)
  end

  defp build_error(error_attrs, self = %Parseus{errors: errors}, context) do
    key = Keyword.fetch!(context, :key)
    proc = Keyword.fetch!(context, :proc)
    new_error =
      error_attrs
      |> Keyword.merge(key: key, source: proc)
      |> Error.build()

    new_errors = [new_error | errors]

    %{self | errors: new_errors}
  end
end
