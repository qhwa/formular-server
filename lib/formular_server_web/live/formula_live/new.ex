defmodule Formular.ServerWeb.FormulaLive.New do
  @moduledoc false

  alias Formular.Server.Accounts
  alias Formular.Server.Formulas
  alias Formular.Server.Formulas.Revision

  use Formular.ServerWeb, :live_view

  require Logger

  @impl true
  def mount(_params, %{"user_token" => token}, socket) do
    {:ok, assign(socket, :current_user, Accounts.get_user_by_session_token(token))}
  end

  @impl true
  def handle_params(%{}, _, socket) do
    changeset = Formulas.new_formula(%{})

    {:noreply,
     socket
     |> assign(:changeset, changeset)
     |> push_event("set-code", %{code: ""})}
  end

  @impl true
  def handle_event("validate", %{"formula" => params}, socket) do
    changeset =
      Formulas.new_formula(params)
      |> Map.put(:action, :insert)

    case changeset do
      %{valid?: true} ->
        {:noreply,
         socket
         |> assign(:changeset, changeset)
         |> push_event("error", %{})}

      _ ->
        {:noreply,
         socket
         |> assign(:changeset, changeset)
         |> push_event("error", Revision.get_errors(changeset))}
    end
  end

  def handle_event("save", %{"formula" => params}, socket) do
    %{current_user: current_user} = socket.assigns

    case Formulas.create_formula(params, current_user) do
      {:ok, formula} ->
        {:noreply,
         socket
         |> put_flash(:info, "formula created")
         |> redirect(to: Routes.formula_show_path(socket, :show, formula))}

      {:error, %Ecto.Changeset{} = changeset} ->
        Logger.error("Error creating formula: #{inspect(changeset)}")

        {:noreply,
         socket
         |> assign(changeset: changeset)
         |> push_event("error", Revision.get_errors(changeset))}
    end
  end
end
