defmodule Formular.ServerWeb.Api.RuleControllerTest do
  alias Formular.Server.Formulas

  use Formular.ServerWeb.ConnCase, async: true

  import Formular.Server.Factory
  import SignInUser

  @table """
  C || value
  1 || one
  2 || two
  3 || three
  """

  describe "PATCH /api/rules/:name" do
    setup [:sign_in_user]

    setup do
      %{formula: insert(:formula, code: @table, syntax: "Decision Table")}
    end

    test "returns 400 when input argument is missing", %{
      formula: formula,
      conn: conn
    } do
      conn = patch(conn, Routes.rule_path(conn, :update, formula), %{id: 1})

      assert json_response(conn, 400)
    end

    test "updates formula", %{formula: formula, conn: conn} do
      conn =
        conn
        |> patch(Routes.rule_path(conn, :update, formula), %{id: 1, output: %{value: "once"}})

      assert json_response(conn, 200)

      {:ok, formula} = Formulas.get_formula_by_name(formula.name)
      assert formula.code == "C || value\n1 || once\n2 || two\n3 || three"
    end
  end
end
