defmodule Formular.ServerWeb.FormulaLive.Edit do
  @moduledoc false

  alias Formular.Server.Accounts
  alias Formular.Server.Formulas
  alias Formular.Server.Formulas.Revision

  use Formular.ServerWeb, :live_view
  import Formular.ServerWeb.TablexView

  require Logger

  @impl true
  def mount(_params, %{"user_token" => token} = _session, socket) do
    {:ok, assign(socket, :current_user, Accounts.get_user_by_session_token(token))}
  end

  @impl true
  def handle_params(%{"name" => name}, _, socket) do
    Formulas.subscribe("formula:#{name}")

    formula = get_formula(name)

    changeset = Formulas.change_formula(formula)

    socket =
      socket
      |> assign(:page_title, "Editing #{name}")
      |> assign(:formula, formula)
      |> assign(:changeset, changeset)
      |> assign(:live_action, :edit)

    {:noreply, socket}
  end

  defp get_formula(name) do
    Formulas.get_formula_by_name!(name)
  end

  @impl true
  def handle_event("save", %{"revision" => revision_params}, socket) do
    formula = socket.assigns.formula
    user = socket.assigns.current_user

    case Formulas.create_revision(formula, user, revision_params) do
      {:ok, revision} ->
        {:noreply,
         socket
         |> assign(:revision, revision)
         |> assign(:live_action, :notify_new_rev)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> assign(:changeset, changeset)
         |> push_event("error", Revision.get_errors(changeset))}
    end
  end

  def handle_event("validate", %{"revision" => revision_params}, socket) do
    changeset =
      socket.assigns.formula
      |> Formulas.new_revision(socket.assigns.current_user, revision_params)

    case changeset do
      %{valid?: true} ->
        {:noreply,
         socket
         |> push_event("error", %{})}

      _ ->
        {
          :noreply,
          socket
          |> push_event("error", Revision.get_errors(changeset))
        }
    end
  end

  def handle_event("publish", _params, socket) do
    revision = %{socket.assigns.revision | formula: socket.assigns.formula}

    case Formulas.publish_revision(revision) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Formula updated successfully.")
         |> push_redirect(to: Routes.formula_show_path(socket, :show, socket.assigns.formula))}

      {:error, reason} ->
        {:noreply, put_flash(socket, :error, "Error: #{inspect(reason)}")}
    end
  end
end
