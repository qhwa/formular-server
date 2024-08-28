# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Formular.Server.Repo.insert!(%Formular.Server.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
Formular.Server.Repo.insert!(%Formular.Server.Formulas.Formula{
  name: "test",
  code: """
    cond do
      true -> :ok
    end
  """
})
