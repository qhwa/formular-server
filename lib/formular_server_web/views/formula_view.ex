defmodule Formular.ServerWeb.FormulaView do
  use Formular.ServerWeb, :view

  def render_decision_table(code) do
    case Tablex.new(code) do
      %{} = table ->
        table |> TablexView.render() |> raw()

      {:error, _} ->
        code
    end
  end
end
