defmodule Formular.ServerWeb.FormulaLive.FormComponent do
  @moduledoc false

  use Formular.ServerWeb, :live_component

  alias Formular.Server.Formulas

  @impl true
  def update(%{formula: formula} = assigns, socket) do
    changeset = Formulas.change_formula(formula)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"formula" => formula_params}, socket) do
    changeset =
      socket.assigns.formula
      |> Formulas.change_formula(formula_params, socket.assigns.action)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"formula" => formula_params}, socket) do
    %{action: action, current_user: user} = socket.assigns
    save_formula(socket, action, formula_params, user)
  end

  defp save_formula(socket, :edit, formula_params, user) do
    formula = socket.assigns.formula

    case Formulas.update_formula(formula, formula_params, user) do
      {:ok, revision} ->
        {:noreply,
         socket
         |> put_flash(:info, "New revision of formula created.")
         |> push_redirect(to: Routes.formula_show_path(socket, :show_rev, formula, revision))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_formula(socket, :new, formula_params, user) do
    case Formulas.create_formula(formula_params, user) do
      {:ok, _formula} ->
        {:noreply,
         socket
         |> put_flash(:info, "Formula created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
