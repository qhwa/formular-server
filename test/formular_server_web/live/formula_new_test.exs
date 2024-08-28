defmodule Formular.ServerWeb.FormulaNewTest do
  use Formular.ServerWeb.ConnCase

  import Phoenix.LiveViewTest
  import Formular.Server.Factory

  defp create_formula(_) do
    formula = insert(:formula)
    %{formula: formula}
  end

  describe "Edit" do
    setup [:register_and_log_in_user, :create_formula]

    test "saves new formula", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, Routes.formula_new_path(conn, :new))
      assert html =~ "New formula"
    end
  end
end
