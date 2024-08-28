defmodule Formular.Server.Tracker do
  @moduledoc """
  Client consumer tracker.
  """

  use Phoenix.Tracker
  require Logger

  def start_link(opts) do
    opts = Keyword.put(opts, :name, __MODULE__)
    Phoenix.Tracker.start_link(__MODULE__, opts, opts)
  end

  @impl true
  def init(opts) do
    server = Keyword.fetch!(opts, :pubsub_server)
    {:ok, %{pubsub_server: server, node_name: Phoenix.PubSub.node_name(server)}}
  end

  @impl true
  def handle_diff(diff, state) do
    for {topic, {joins, leaves}} <- diff do
      for {client, meta} <- joins do
        Logger.info("presence join: client \"#{inspect(client)}\" with meta #{inspect(meta)}")
        msg = {:join, client, meta}
        Phoenix.PubSub.direct_broadcast!(state.node_name, state.pubsub_server, topic, msg)
      end

      for {client, meta} <- leaves do
        Logger.info("presence leave: client \"#{inspect(client)}\" with meta #{inspect(meta)}")
        msg = {:leave, client, meta}
        Phoenix.PubSub.direct_broadcast!(state.node_name, state.pubsub_server, topic, msg)
      end
    end

    {:ok, state}
  end
end
