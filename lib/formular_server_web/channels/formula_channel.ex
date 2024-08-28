defmodule Formular.ServerWeb.FormulaChannel do
  @moduledoc false

  alias Formular.Server.Formulas
  use Formular.ServerWeb, :channel
  require Logger

  @dialyzer {:no_match, join: 3}

  @impl true
  def join("formula:" <> name = topic, payload, socket) do
    Logger.info(["New client joined channel: formula:#{name}, ", inspect(payload)])

    if authorized?(payload) do
      case Formulas.get_formula_by_name(name, compile: true) do
        {:ok, formula} ->
          do_join(formula, topic, payload)
          {:ok, assign(socket, :formula, formula)}

        {:error, :not_found} ->
          {:error, %{reason: "notfound"}}
      end
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  @impl true
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  def handle_in("code_updated", _payload, socket) do
    Logger.info("[#{socket.assigns.formula.name}] Code was successfully updated in the client.")
    {:noreply, socket}
  end

  def handle_in("code_update_error", payload, socket) do
    Logger.error(
      "[#{socket.assigns.formula.name}] Code update failed, payload from client: #{inspect(payload)}."
    )

    # TODO: inform the user about the failure.
    {:noreply, socket}
  end

  @impl true
  def handle_info(:after_join, socket) do
    push(socket, "data", socket.assigns.formula)

    {:noreply, socket}
  end

  def handle_info({:update, formula}, socket) do
    push(socket, "data", formula)

    {:noreply, assign(socket, :formula, formula)}
  end

  def handle_info({:join, _client, _meta}, socket) do
    {:noreply, socket}
  end

  def handle_info({:leave, _client, _meta}, socket) do
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end

  defp do_join(formula, topic, payload) do
    Formulas.subscribe("formula:#{formula.id}")

    Phoenix.Tracker.track(
      Formular.Server.Tracker,
      self(),
      topic,
      %{client_name: Map.get(payload, "client_name", "UNKNOWN")},
      %{}
    )

    send(self(), :after_join)
  end
end
