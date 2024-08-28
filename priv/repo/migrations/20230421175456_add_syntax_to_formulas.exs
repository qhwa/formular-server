defmodule Formular.Server.Repo.Migrations.AddSyntaxToFormulas do
  use Ecto.Migration

  def change do
    alter table(:formulas) do
      add :syntax, :string
    end
  end
end
