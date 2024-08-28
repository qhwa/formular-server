defmodule Formular.Server.Repo.Migrations.CreateFormulas do
  use Ecto.Migration

  def change do
    create table(:formulas) do
      add :name, :string
      add :code, :text

      timestamps()
    end

    create unique_index(:formulas, [:name])
  end
end
