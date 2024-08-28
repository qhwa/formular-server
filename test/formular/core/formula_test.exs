defmodule Formular.Core.FormulaTest do
  use ExUnit.Case, async: true

  alias Formular.Core.Branch
  alias Formular.Core.Formula

  describe "to_string" do
    test "it works with empty branches" do
      assert "nil" = render(%Formula{})
    end

    test "it works with one branch" do
      formula = %Formula{
        branches: [
          %Branch{
            expression: "1 + 5"
          }
        ]
      }

      assert render(formula) ==
               """
               cond do
                 true -> "1 + 5"
               end
               """
               |> String.trim()
    end

    test "it works with one branch which contains a condition" do
      formula = %Formula{
        branches: [
          %Branch{
            condition: {:match, quote(do: %{id: 5}), :store},
            expression: :ok
          }
        ]
      }

      assert render(formula) ==
               """
               cond do
                 match?(%{id: 5}, store) -> :ok
               end
               """
               |> String.trim()
    end
  end

  defp render(formula),
    do: formula |> Formula.to_string() |> IO.iodata_to_binary()
end
