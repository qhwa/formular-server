defmodule Formular.ServerWeb.ModalComponent do
  @moduledoc false

  use Formular.ServerWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div
      id={@id}
      class="modal show phx-modal modal-sm"
      style="display: block;"
      phx-capture-click="close"
      phx-window-keydown="close"
      phx-key="escape"
      phx-target={@myself}
      phx-page-loading
    >
      <div class="phx-modal-content modal-content">
        <.link patch={@return_to} class="phx-modal-close btn btn-close">&times;</.link>
        <%= live_component(@opts) %>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("close", _, socket) do
    {:noreply, push_patch(socket, to: socket.assigns.return_to)}
  end
end
