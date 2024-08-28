defmodule Formular.ServerWeb.FormulaLiveTest do
  use Formular.ServerWeb.ConnCase

  import Phoenix.LiveViewTest
  import Formular.Server.Factory

  defp create_formula(_) do
    formula = insert(:formula)
    %{formula: formula}
  end

  describe "Index" do
    setup [:register_and_log_in_user, :create_formula]

    test "lists all formulas", %{conn: conn, formula: formula} do
      {:ok, _index_live, html} = live(conn, Routes.formula_index_path(conn, :index))

      assert html =~ "Listing Formulas"
      assert html =~ formula.name
    end
  end

  describe "Show" do
    setup [:register_and_log_in_user, :create_formula]

    test "displays formula", %{conn: conn, formula: formula} do
      {:ok, _show_live, html} = live(conn, Routes.formula_show_path(conn, :show, formula))

      assert html =~ "Formula"
      assert html =~ formula.name
    end
  end
end
