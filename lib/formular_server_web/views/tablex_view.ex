defmodule Formular.ServerWeb.TablexView do
  use Formular.ServerWeb, :view

  def render_tablex_editor(formula) do
    with %{} = table <- Tablex.new(formula.code),
         html when is_binary(html) <- TablexView.render(table, mode: :editor) do
      {:safe, html}
    else
      err ->
        {:safe, "<div class=\"alert alert-danger\">Invalid formula: #{inspect(err)}</div>"}
    end
  end
end
