defmodule Poxa.EventHandler do
  @moduledoc """
  This module contains Cowboy HTTP handler callbacks to request on /apps/:app_id/events

  More info on Cowboy HTTP handler at: http://ninenines.eu/docs/en/cowboy/HEAD/guide/http_handlers

  More info on Pusher events at: http://pusher.com/docs/rest_api
  """
  alias Poxa.Authentication
  alias Poxa.PusherEvent
  alias Poxa.Event
  require Logger

  @doc false
  def init(_transport, _req, _opts), do: {:upgrade, :protocol, :cowboy_rest}

  def allowed_methods(req, state), do: {["POST"], req, state}

  @invalid_event_json Poison.encode!(%{error: "Event must have channel(s), name, and data"})

  @doc """
  If the body is not JSON or not a valid PusherEvent this function will
  guarantee that 400 will be returned
  """
  def malformed_request(req, state) do
    {:ok, body, req} = :cowboy_req.body(req)
    case Poison.decode(body) do
      {:ok, data} ->
        case PusherEvent.build(data) do
          {:ok, event} -> {false, req, %{body: body, event: event}}
          _ ->
            req = :cowboy_req.set_resp_body(@invalid_event_json, req)
            {true, req, state}
        end
      _ ->
        req = :cowboy_req.set_resp_body(@invalid_event_json, req)
        {true, req, state}
    end
  end

  @authentication_error_json Poison.encode!(%{error: "Authentication error"})

  @doc """
  More info http://pusher.com/docs/rest_api#authentication
  """
  def is_authorized(req, %{body: body} = state) do
    {qs_vals, req} = :cowboy_req.qs_vals(req)
    {method, req} = :cowboy_req.method(req)
    {path, req} = :cowboy_req.path(req)
    if Authentication.check(method, path, body, qs_vals) do
      {true, req, state}
    else
      req = :cowboy_req.set_resp_body(@authentication_error_json, req)
      {{false, "Authentication error"}, req, state}
    end
  end


  @invalid_data_size_json Poison.encode!(%{error: "Data key must be smaller than 10KB"})

  @doc """
  The event data can't be greater than payload_limit which defaults to 10KB
  """
  def valid_entity_length(req, %{event: event} = state) do
    {:ok, payload_limit} = Application.fetch_env(:poxa, :payload_limit)
    valid = byte_size(event.data) <= payload_limit
    req = if valid do
            req
          else
            :cowboy_req.set_resp_body(invalid_data_size_json(payload_limit), req)
          end
    {valid, req, state}
  end

  @doc false
  def content_types_accepted(req, state) do
    {[{{"application", "json", :*}, :post}], req, state}
  end

  @doc false
  def content_types_provided(req, state) do
    {[{{"application", "json", []}, :undefined}], req, state}
  end

  @doc false
  def post(req, %{event: event}) do
    Logger.debug "Publish Event."
    PusherEvent.publish(event)
    Event.notify(:api_message, %{channels: event.channels, name: event.name, socket_id: nil})
    req = :cowboy_req.set_resp_body("{}", req)
    {true, req, nil}
  end

  @doc false
  defp invalid_data_size_json(payload_limit) do
    JSX.encode!(%{error: "Data key must be smaller than #{payload_limit}B"})
  end
end
