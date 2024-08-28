defmodule Formular.ServerWeb.FormulaLive.Show do
  @moduledoc false

  alias Formular.Server.Accounts
  alias Formular.Server.Accounts.User
  alias Formular.Server.Formulas
  alias Formular.ServerWeb.UserSettingsView

  use Formular.ServerWeb, :live_view
  import Formular.ServerWeb.FormulaView

  @impl true
  def mount(_params, %{"user_token" => token}, socket) do
    {:ok, assign(socket, :current_user, Accounts.get_user_by_session_token(token))}
  end

  @impl true
  def handle_params(%{"name" => name} = params, _, socket) do
    socket =
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:formula, get_formula(name))
      |> subscribe()
      |> update_clients()
      |> maybe_assign_revision(params)

    {:noreply, socket}
  end

  defp get_formula(name) do
    Formulas.get_formula_by_name!(name)
    |> Formular.Server.Repo.preload([:current_revision, revisions: [:user]])
  end

  defp subscribe(%{assigns: %{formula: %{id: id}}} = socket) do
    Formulas.subscribe("formula:#{id}")
    socket
  end

  defp subscribe(socket) do
    socket
  end

  defp update_clients(socket) do
    name = socket.assigns.formula.name

    socket
    |> assign(:client_apps, client_apps("formula:#{name}"))
  end

  defp client_apps(topic) do
    Phoenix.Tracker.list(Formular.Server.Tracker, topic)
    |> Stream.map(fn {client, _} -> client.client_name end)
    |> Enum.frequencies()
  end

  defp maybe_assign_revision(%{assigns: %{live_action: :show_rev}} = socket, %{"id" => id}) do
    rev =
      Formulas.get_revision!(id)
      |> Formular.Server.Repo.preload(:user)

    socket
    |> assign(:revision, %{rev | formula: socket.assigns.formula})
  end

  defp maybe_assign_revision(socket, _params) do
    socket
  end

  @impl true
  def handle_info({:update, formula}, socket) do
    {:noreply, assign(socket, :formula, formula)}
  end

  def handle_info({:join, _client, _meta}, socket) do
    {:noreply, update_clients(socket)}
  end

  def handle_info({:leave, _client, _meta}, socket) do
    {:noreply, update_clients(socket)}
  end

  defp page_title(:show), do: "Formula"
  defp page_title(:edit), do: "Edit Formula"
  defp page_title(:show_rev), do: "Revision"

  defp display_user(nil), do: ""

  defp display_user(%User{} = user),
    do: ["createdy by ", UserSettingsView.display_name(user)]
end
