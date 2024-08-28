defmodule Formular.ServerWeb.FormulaLive.Index do
  @moduledoc false

  use Formular.ServerWeb, :live_view

  alias Formular.Server.Formulas
  alias Formular.Server.Formulas.Formula

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:formulas, list_formulas())

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply,
     apply_action(socket, socket.assigns.live_action, params)
     |> assign_filters(params)}
  end

  defp assign_filters(socket, %{"consumer" => consumer}) when is_binary(consumer) do
    socket
    |> assign(:consumer, consumer)
  end

  defp assign_filters(socket, _params), do: socket |> assign(:consumer, nil)

  defp apply_action(socket, :edit, %{"name" => name}) do
    socket
    |> assign(:page_title, "Edit Formula")
    |> assign(:formula, Formulas.get_formula_by_name!(name))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Formula")
    |> assign(:formula, %Formula{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Formulas")
    |> assign(:formula, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    formula = Formulas.get_formula!(id)
    {:ok, _} = Formulas.delete_formula(formula)

    {:noreply, assign(socket, :formulas, list_formulas())}
  end

  def handle_event("search", %{"value" => ""}, socket) do
    {:noreply, socket |> assign(:formulas, list_formulas())}
  end

  def handle_event("search", %{"value" => value}, socket) do
    search_results = Formulas.search_formulas(value)
    {:noreply, socket |> assign(:formulas, search_results)}
  end

  def handle_event("search", _params, socket) do
    {:noreply, socket}
  end

  defp list_formulas do
    Formulas.list_formulas()
  end
end
