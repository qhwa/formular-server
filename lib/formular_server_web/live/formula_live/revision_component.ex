defmodule Formular.ServerWeb.FormulaLive.RevisionComponent do
  @moduledoc false

  use Formular.ServerWeb, :live_component

  alias Formular.Server.Accounts.User
  alias Formular.Server.Formulas

  import Canada, only: [can?: 2]

  @impl true
  def handle_event("edit_note", _params, socket) do
    {:noreply, start_editing(socket)}
  end

  def handle_event("cancel", _params, socket) do
    {:noreply, stop_editing(socket)}
  end

  def handle_event(
        "validate",
        %{"revision" => revision_params},
        %{assigns: %{revision: rev}} = socket
      ) do
    changeset = Formulas.change_revision(rev, revision_params)
    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event(
        "update_note",
        %{"revision" => rev_params},
        %{assigns: %{revision: rev}} = socket
      ) do
    case Formulas.update_revision(rev, rev_params) do
      {:ok, rev} ->
        {:noreply,
         socket
         |> put_flash(:info, "Note successfully saved.")
         |> stop_editing()
         |> assign(:revision, rev)}

      {:error, reason} ->
        {:noreply, put_flash(socket, :error, "Error: #{inspect(reason)}")}
    end
  end

  def handle_event("publish", _params, socket) do
    case Formulas.publish_revision(socket.assigns.revision) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Formula updated successfully.")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, reason} ->
        {:noreply, put_flash(socket, :error, "Error: #{inspect(reason)}")}
    end
  end

  defp start_editing(%{assigns: %{revision: rev}} = socket) do
    socket
    |> assign(:editing_note, true)
    |> assign(:changeset, Formulas.change_revision(rev, %{}))
  end

  defp stop_editing(socket) do
    socket
    |> assign(:editing_note, false)
    |> assign(:changeset, nil)
  end

  defp display_user(nil), do: ""

  defp display_user(%User{} = user),
    do: ["createdy by ", Formular.ServerWeb.UserSettingsView.display_name(user)]
end
