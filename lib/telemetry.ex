defmodule DialupSite.Telemetry do
  require Logger

  def attach do
    :telemetry.attach_many(
      "dialup-site-logger",
      [
        [:dialup, :websocket, :connect],
        [:dialup, :websocket, :disconnect],
        [:dialup, :event, :stop],
        [:dialup, :event, :exception],
        [:dialup, :navigate, :stop],
        [:dialup, :navigate, :exception]
      ],
      &__MODULE__.handle/4,
      nil
    )
  end

  def handle([:dialup, :websocket, :connect], _measurements, meta, _config) do
    Logger.info("[Dialup] WebSocket connected: #{meta.session_id}")
  end

  def handle([:dialup, :websocket, :disconnect], _measurements, meta, _config) do
    Logger.info("[Dialup] WebSocket disconnected: #{meta.session_id}")
  end

  def handle([:dialup, :event, :stop], %{duration: d}, meta, _config) do
    ms = System.convert_time_unit(d, :native, :millisecond)
    Logger.info("[Dialup] Event #{meta.event} on #{meta.path} (#{ms}ms)")
  end

  def handle([:dialup, :event, :exception], %{duration: d}, meta, _config) do
    ms = System.convert_time_unit(d, :native, :millisecond)

    Logger.error(
      "[Dialup] Event #{meta.event} on #{meta.path} failed (#{ms}ms): #{Exception.message(meta.reason)}"
    )
  end

  def handle([:dialup, :navigate, :stop], %{duration: d}, meta, _config) do
    ms = System.convert_time_unit(d, :native, :millisecond)
    Logger.info("[Dialup] Navigate to #{meta.path} (#{ms}ms)")
  end

  def handle([:dialup, :navigate, :exception], %{duration: d}, meta, _config) do
    ms = System.convert_time_unit(d, :native, :millisecond)

    Logger.error(
      "[Dialup] Navigate to #{meta.path} failed (#{ms}ms): #{Exception.message(meta.reason)}"
    )
  end

  def handle(_event, _measurements, _meta, _config), do: :ok
end
