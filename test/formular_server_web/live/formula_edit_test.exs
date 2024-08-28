defmodule Formular.ServerWeb.FormulaEditTest do
  use Formular.ServerWeb.ConnCase

  import Phoenix.LiveViewTest
  import Formular.Server.Factory

  defp create_formula(_) do
    %{formula: insert(:formula, name: "some_name")}
  end

  describe "Edit" do
    setup [:register_and_log_in_user, :create_formula]

    test "it renders the formula", %{conn: conn, formula: formula} do
      {:ok, _index_live, html} = live(conn, Routes.formula_edit_path(conn, :edit, formula))

      assert html =~ "some_name"
    end
  end
end
