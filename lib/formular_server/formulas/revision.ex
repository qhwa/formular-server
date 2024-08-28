defmodule Formular.Server.Formulas.Revision do
  @moduledoc """
  Revision model.

  A formula can have multiple revisions and one active revision.
  """

  alias Formular.Server.Accounts.User
  alias Formular.Server.Formulas.FormatChangedCode
  alias Formular.Server.Formulas.FormatError
  alias Formular.Server.Formulas.Formula

  use Ecto.Schema
  import Ecto.Changeset

  @type t() :: Ecto.Schema.t()

  schema "revisions" do
    field :code, :string
    field :published, :boolean, default: false
    field :note, :string
    field :syntax, :string, virtual: true

    belongs_to :formula, Formula
    belongs_to :user, User

    timestamps()
  end

  @doc false
  @spec creating_changeset(t(), any()) :: Ecto.Changeset.t()
  def creating_changeset(revision, attrs) do
    revision
    |> cast(attrs, [:code, :note, :syntax])
    |> validate_required([:code, :user])
    |> validate_and_format_code()
  end

  defp validate_and_format_code(changeset) do
    FormatChangedCode.validate_and_format_code(changeset)
  end

  @doc false
  def changing_changeset(revision, attrs) do
    revision
    |> cast(attrs, [:note])
  end

  @doc false
  def publishing_changeset(revision) do
    revision
    |> cast(%{published: true}, [:published])
    |> set_formula_revision(revision.formula, revision)
  end

  defp set_formula_revision(changeset, formula, revision) do
    changeset
    |> put_assoc(
      :formula,
      Formula.publishing_changeset(formula, revision)
    )
  end

  @spec get_errors(Ecto.Changeset.t()) :: map()
  def get_errors(changeset) do
    traverse_errors(changeset, fn {msg, opts} ->
      case Keyword.get(opts, :format_error) do
        %FormatError{} = err ->
          err

        _ ->
          msg
      end
    end)
  end
end
