defmodule Formular.Server.FormulasTest do
  use Formular.Server.DataCase

  alias Formular.Server.Formulas

  describe "formulas" do
    alias Formular.Server.Formulas.Formula

    import Formular.Server.Factory

    defp formula_fixture do
      insert(:formula)
    end

    @invalid_attrs %{code: nil, name: nil}

    test "list_formulas/0 returns all formulas" do
      formula = formula_fixture()

      assert formula.id in (list_formulas() |> Enum.map(& &1.id))
    end

    test "get_formula!/1 returns the formula with given id" do
      formula = formula_fixture()

      assert Formulas.get_formula!(formula.id) |> Repo.preload(revisions: :user) ==
               Repo.preload(formula, :current_revision)
    end

    test "create_formula/1 with valid data creates a formula" do
      valid_attrs = %{code: "1", name: "some_name"}

      assert {:ok, %Formula{} = formula} = Formulas.create_formula(valid_attrs, insert(:user))
      assert formula.code == "1"
      assert formula.name == "some_name"
    end

    test "create_formula/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Formulas.create_formula(@invalid_attrs, insert(:user))
    end

    test "update_formula/2 with valid data updates the formula" do
      formula = formula_fixture()
      update_attrs = %{code: ":ok", name: "some_updated_name"}

      assert {:ok, rev} = Formulas.update_formula(formula, update_attrs, insert(:user))
      assert rev.code == ":ok"
    end

    test "update_formula/2 with invalid data returns error changeset" do
      formula = formula_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Formulas.update_formula(formula, @invalid_attrs, insert(:user))

      formula = Repo.preload(formula, [:current_revision, :revisions])
      assert formula == Formulas.get_formula!(formula.id) |> Repo.preload(revisions: :user)
    end

    test "delete_formula/1 deletes the formula" do
      formula = formula_fixture()
      assert {:ok, %Formula{}} = Formulas.delete_formula(formula)
      assert_raise Ecto.NoResultsError, fn -> Formulas.get_formula!(formula.id) end
    end

    test "change_formula/1 returns a formula changeset" do
      formula = formula_fixture()
      assert %Ecto.Changeset{} = Formulas.change_formula(formula)
    end

    defp list_formulas do
      Formulas.list_formulas()
      |> Repo.preload([:current_revision, :revisions])
    end
  end
end
