defmodule Formular.Server.Repo.Migrations.AddRevisionIdToFormulas do
  use Ecto.Migration

  def change do
    alter table(:formulas) do
      add :current_revision_id, references(:revisions)
    end
  end
end
