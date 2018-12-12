defmodule Surgex.Appsignal.EctoLogger do
  @moduledoc """
  Integration for logging Ecto queries.

  This is an override of `Appsignal.Ecto` - backwards compatible with the original but with
  additional options available in the `handle_event/4` function.

  """

  require Logger

  alias Appsignal.{Transaction, TransactionRegistry}

  @nano_seconds :erlang.convert_time_unit(1, :nano_seconds, :native)
  @default_event_name "query.ecto"
  @query_stages [:queue, :query, :decode]

  @doc """
  Handles Ecto event generated via Telemetry.

  This is an override of `Appsignal.Ecto.handle_event/4` - backwards compatible with the original
  but with additional options controlled via Telemetry configuration list.

  ## Options

  - `:event_name` - allows to adjust logged event name and include app name/repo name in it. The
    value passed may be string literal or list of event name parts which may include string
    literals or following special atoms:

    - `:app` - name of app that owns specific Ecto repo
    - `:repo` - name of the specific Ecto repo
    - `:method` - Ecto method (currently just "query")

  - `:query_stages` - allows to alter the default duration calc behavior in which all three Ecto
    stages (`:queue`, `:query` and `:decode`) are included in the event. The optimal scenario
    would be to track these separately but Appsignal NIF currently doesn't give an option to log
    multiple events backwards in time so this option allows to exclude some of these stages and/or
    configure multiple events for specific stages. You can set this option to list of stages that
    should be included or to `:all` atom which will result in generating both the `ecto` event for
    whole event and separate `ecto_<stage>` subevents for each stage.

  ## Examples

  Multiple repos:

      # lib/my_app/application.ex

      Telemetry.attach_many(
        "my-app-ecto-appsignal",
        [
          [:my_app, :some_repo, :query],
          [:my_app, :other_repo, :query]
        ],
        Surgex.Appsignal.EctoLogger,
        :handle_event,
        event_name: ["ecto", :repo, :method]
      )

  Multiple apps eg. in Umbrella:

      # apps/some_app/lib/some_app/application.ex

      Telemetry.attach(
        "some-app-ecto-appsignal",
        [:some_app, :repo, :query],
        Surgex.Appsignal.EctoLogger,
        :handle_event,
        event_name: ["ecto", :app, :method]
      )

      # apps/other_app/lib/other_app/application.ex

      Telemetry.attach(
        "other-app-ecto-appsignal",
        [:other_app, :repo, :query],
        Surgex.Appsignal.EctoLogger,
        :handle_event,
        event_name: ["ecto", :app, :method]
      )

  All stages logged together with main event:

      # lib/my_app/application.ex

      Telemetry.attach(
        "my-app-ecto-appsignal",
        [:my_app, :repo, :query],
        Surgex.Appsignal.EctoLogger,
        :handle_event,
        event_name: ["ecto", :method],
        queue_stages: :all
      )

  Customization of the above - additional log for queue time without query and decode times:

      # lib/my_app/application.ex

      Telemetry.attach(
        "my-app-ecto-appsignal",
        [:my_app, :repo, :query],
        Surgex.Appsignal.EctoLogger,
        :handle_event,
        event_name: ["ecto", :method]
      )

      Telemetry.attach(
        "my-app-ecto-appsignal-queue",
        [:my_app, :repo, :query],
        Surgex.Appsignal.EctoLogger,
        :handle_event,
        event_name: ["ecto_queue", :method],
        query_stages: [:queue]
      )

  """
  def handle_event(telemetry_event, latency, metadata, nil) do
    handle_event(telemetry_event, latency, metadata, [])
  end

  def handle_event(telemetry_event, _latency, metadata, config) do
    event_name = Keyword.get(config, :event_name, @default_event_name)
    query_stages = Keyword.get(config, :query_stages, @query_stages)
    event_name_string = get_event_name(event_name, telemetry_event)

    log(metadata, event_name_string, query_stages)
  end

  defp get_event_name(event_name, telemetry_event)

  defp get_event_name(event_name, _) when is_binary(event_name) do
    event_name
  end

  defp get_event_name(event_name_parts, telemetry_event) when is_list(event_name_parts) do
    event_name_parts
    |> Enum.map(&resolve_event_name_part(&1, telemetry_event))
    |> Enum.reverse()
    |> Enum.join(".")
  end

  defp resolve_event_name_part(part, telemetry_event)
  defp resolve_event_name_part(part, _) when is_binary(part), do: part
  defp resolve_event_name_part(:app, [app, _, _]), do: app
  defp resolve_event_name_part(:repo, [_, repo, _]), do: repo
  defp resolve_event_name_part(:method, [_, _, method]), do: method

  @doc """
  Logs the event via Ecto logger instead of Telemetry (Ecto before version 3.0).

  This is an override of `Appsignal.Ecto.log/1` - backwards compatible with the original but with
  additional control over event name and query stages that are included in event duration both of
  which are used by `handle_event/4`.

  """
  def log(entry) do
    log(entry, @default_event_name, @query_stages)
  end

  @doc false
  def log(entry, event_name, query_stages) do
    # See if we have a transaction registered for the current process
    case apply(TransactionRegistry, :lookup, [self()]) do
      nil ->
        # skip
        :ok

      %{__struct__: Transaction} = transaction ->
        # record the event
        log_stages(transaction, event_name, entry, query_stages)
    end

    entry
  end

  defp log_stages(transaction, event_name, entry, query_stages)

  defp log_stages(transaction, event_name, entry, :all) do
    log_stages(transaction, event_name, entry, @query_stages)

    Enum.each(@query_stages, fn stage ->
      total_time = get_total_time(entry, [stage])
      duration = trunc(total_time / @nano_seconds)
      event_name = event_name <> "_" <> to_string(stage)
      apply(Transaction, :record_event, [transaction, event_name, "", entry.query, duration, 10])
    end)
  end

  defp log_stages(transaction, event_name, entry, query_stages) when is_list(query_stages) do
    total_time = get_total_time(entry, query_stages)
    duration = trunc(total_time / @nano_seconds)
    apply(Transaction, :record_event, [transaction, event_name, "", entry.query, duration, 1])
  end

  defp get_total_time(entry, stages) do
    Enum.reduce(@query_stages, 0, &reduce_total_time_for_query_stage(entry, &1, stages, &2))
  end

  defp reduce_total_time_for_query_stage(entry, stage, included_stages, accum) do
    if stage in included_stages do
      accum + Map.get(entry, :"#{stage}_time", 0)
    else
      accum
    end
  end
end
