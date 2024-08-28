defmodule Formular.Server.Repo.Migrations.CreateRevisions do
  use Ecto.Migration

  def change do
    create table(:revisions) do
      add :code, :text
      add :published, :boolean, default: false, null: false
      add :formula_id, references(:formulas, on_delete: :delete_all)

      timestamps()
    end

    create index(:revisions, [:formula_id])
    create index(:revisions, [:inserted_at])
  end
end
