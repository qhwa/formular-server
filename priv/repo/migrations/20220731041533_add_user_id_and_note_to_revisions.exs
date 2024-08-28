defmodule Formular.Server.Repo.Migrations.AddUserIdAndNoteToRevisions do
  use Ecto.Migration

  def change do
    alter table(:revisions) do
      add :user_id, references(:users, on_delete: :nothing)
      add :note, :text
    end

    create index(:revisions, [:user_id])
  end
end
