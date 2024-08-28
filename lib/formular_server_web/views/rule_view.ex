defmodule Formular.ServerWeb.Api.RuleView do
  alias Tablex.Rules.Rule

  use Formular.ServerWeb, :view

  def render("index.json", %{rules: rules}) do
    rules
    |> Enum.map(fn %Rule{} = rule ->
      %{
        id: rule.id,
        inputs: render_kv(rule.inputs),
        outputs: render_kv(rule.outputs)
      }
    end)
  end

  defp render_kv(kvs) do
    kvs
    |> Map.new(fn {path, value} ->
      {Enum.join(path, "."), Tablex.Formatter.Value.render_value(value)}
    end)
  end
end
