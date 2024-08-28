defmodule Formular.ServerWeb.LiveHelpers do
  @moduledoc false

  use Phoenix.Component

  @doc """
  Renders a component inside the `Formular.ServerWeb.ModalComponent` component.

  The rendered modal receives a `:return_to` option to properly update
  the URL when the modal is closed.

  ## Examples

      <%= live_modal Formular.ServerWeb.FormulaLive.FormComponent,
        id: @formula.id || :new,
        action: @live_action,
        formula: @formula,
        return_to: Routes.formula_index_path(@socket, :index) %>
  """
  def live_modal(component, opts) do
    path = Keyword.fetch!(opts, :return_to)

    modal_opts = %{
      module: Formular.ServerWeb.ModalComponent,
      id: :modal,
      return_to: path,
      component: component,
      opts: Map.new(opts) |> Map.put(:module, component)
    }

    live_component(modal_opts)
  end

  def format_datetime(datetime) do
    Phoenix.HTML.Tag.content_tag(
      :datetime,
      Timex.from_now(datetime),
      datetime: datetime,
      title: datetime
    )
  end
end
