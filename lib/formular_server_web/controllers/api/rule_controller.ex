defmodule Formular.ServerWeb.Api.RuleController do
  alias Formular.Server.Formulas
  alias Formular.Server.Util.Atomify

  use Formular.ServerWeb, :controller

  @get_schema %{
    "name" => :string,
    "input" => %{}
  }

  @update_schema [
    :union,
    [
      %{
        "name" => :string,
        "input" => %{},
        "output" => %{}
      },
      %{
        "name" => :string,
        "id" => :int,
        "output" => %{}
      }
    ]
  ]

  @doc """
  Returns the list of rules that match the given input.
  """
  def index(conn, params) do
    with :ok <- Skooma.valid?(params, @get_schema),
         %{"name" => name} <- params,
         {:ok, formula} <- Formulas.get_formula_by_name(name) do
      input = Atomify.to_atom_keys(params["input"])
      rules = Formulas.get_rules(formula, input)

      render(conn, :index, rules: rules)
    else
      {:error, reason} ->
        conn
        |> put_status(400)
        |> json(%{success: false, message: inspect(reason)})
    end
  end

  @doc """
  Updates a rule by name and rule id.
  """
  def update(conn, params) do
    with :ok <- Skooma.valid?(params, @update_schema),
         %{"name" => name} <- params,
         {:ok, formula} <- Formulas.get_formula_by_name(name),
         {:ok, rev} <- do_update_rule(formula, params, conn.assigns.current_user),
         {:ok, _rev} <- Formulas.publish_revision(%{rev | formula: formula}) do
      json(conn, %{success: true})
    else
      {:error, reason} ->
        conn
        |> put_status(400)
        |> json(%{success: false, message: inspect(reason)})
    end
  end

  defp do_update_rule(formula, %{"input" => input, "output" => output}, user) do
    Formulas.update_rule_by_input(formula, input, output, user)
  end

  defp do_update_rule(formula, %{"id" => id, "output" => output}, user) do
    Formulas.update_rule_by_id(formula, id, output, user)
  end
end
