defmodule Formular.Server.Formulas.Formula do
  @moduledoc """
  Formula schema definition.
  """

  alias Formular.Server.Formulas.Revision
  use Ecto.Schema

  import Ecto.Changeset
  import Formular.Server.Formulas.FormatChangedCode

  @derive {Phoenix.Param, key: :name}
  @derive {Jason.Encoder, only: [:name, :code]}

  @type t :: Ecto.Schema.t()

  schema "formulas" do
    field :code, :string
    field :name, :string
    field :syntax, :string, default: "Elixir"
    field :compiled_code, :string, virtual: true

    has_many :revisions, Revision, preload_order: [desc: :inserted_at]

    belongs_to :current_revision,
               Revision,
               foreign_key: :current_revision_id,
               on_replace: :update

    timestamps()
  end

  @doc false
  @spec creating_changeset(t(), any()) :: Ecto.Changeset.t()
  def creating_changeset(formula, attrs, format_code \\ true) do
    formula
    |> cast(attrs, [:name, :syntax, :code])
    |> validate_required([:name, :code])
    |> validate_format(:name, ~r/\A[a-z0-9_]+\Z/,
      message: "Invalid format. Only lower case letters, numbers, underscore (_) are allowed."
    )
    |> then(
      if format_code,
        do: &validate_and_format_code(&1),
        else: &validate_code_format(&1)
    )
    |> unique_constraint(:name)
  end

  @doc false
  def updating_changeset(formula, attrs) do
    formula
    |> cast(attrs, [:code])
    |> validate_required([:code])
    |> validate_and_format_code(formula.syntax)
  end

  @doc false
  def publishing_changeset(formula, %Revision{} = revision) do
    formula
    |> cast(%{}, [])
    |> put_change(:code, revision.code)
    |> put_change(:current_revision_id, revision.id)
  end
end
