defmodule Formular.Server.Formulas do
  @moduledoc """
  The Formulas context.
  """

  alias Formular.Server.Accounts.User
  alias Formular.Server.Formulas.Formula
  alias Formular.Server.Formulas.Revision
  alias Formular.Server.Repo
  alias Formular.Server.Util.Atomify

  require Logger

  import Ecto.Query, warn: false

  @type formula :: Ecto.Schema.t()

  @doc """
  Returns the list of formulas.

  ## Examples

      iex> list_formulas()
      [%Formula{}, ...]

  """
  def list_formulas do
    from(f in Formula, order_by: f.name)
    |> Repo.all()
  end

  @doc """
  Gets a single formula.

  Raises `Ecto.NoResultsError` if the Formula does not exist.

  ## Examples

      iex> get_formula!(123)
      %Formula{}

      iex> get_formula!(456)
      ** (Ecto.NoResultsError)

  """
  def get_formula!(id),
    do:
      Repo.get!(Formula, id)
      |> Repo.preload([:revisions, :current_revision])

  @doc """
  Gets a single formula by name.

  Returns `{:error, :not_found}` if not found.

  ## Examples

      iex> get_formula_by_name("test")
      {:ok, %Formula{}}

      iex> get_formula_by_name("NO_EXIST")
      {:error, :not_found}

  """
  @spec get_formula_by_name(binary()) ::
          {:ok, formula()} | {:error, :not_found}
  def get_formula_by_name(name) do
    case Repo.get_by(Formula, name: name) do
      %{} = formular ->
        {:ok, formular}

      nil ->
        {:error, :not_found}
    end
  end

  @doc """
  Gets a single formula by name.

  Options:

  - `compile` - whether to compile the formula code.
  """
  @spec get_formula_by_name(binary(), keyword()) :: {:ok, formula()} | {:error, :not_found}
  def get_formula_by_name(name, opts) do
    with {:ok, formula} <- get_formula_by_name(name) do
      if opts[:compile] do
        %{compiled_code: code} = compile(formula)
        {:ok, %{formula | code: code}}
      else
        {:ok, formula}
      end
    end
  end

  @doc """
  Get a formula by its name
  """
  def get_formula_by_name!(name),
    do: Repo.get_by!(Formula, name: name)

  @spec new_formula(map()) :: Ecto.Changeset.t()
  def new_formula(attrs) do
    Formula.creating_changeset(%Formula{}, attrs, false)
  end

  @doc """
  Creates a formula.

  ## Examples

      iex> create_formula(%{field: value}, user)
      {:ok, %Formula{}}

      iex> create_formula(%{field: bad_value}, user)
      {:error, %Ecto.Changeset{}}

  """
  @spec create_formula(map(), User.t()) :: {:ok, formula()} | {:error, Ecto.Changeset.t()}
  def create_formula(attrs, %User{} = user) do
    new_rev_change = Revision.creating_changeset(%Revision{user: user, published: true}, attrs)

    new_formula_change =
      %Formula{}
      |> Formula.creating_changeset(attrs)
      |> Ecto.Changeset.put_assoc(:revisions, [new_rev_change])

    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.insert(:new_formula, new_formula_change)
      |> Ecto.Multi.update(:publish_rev, fn %{new_formula: f} ->
        %{revisions: [rev]} = Repo.preload(f, :revisions)
        Revision.publishing_changeset(%{rev | formula: f})
      end)

    case Repo.transaction(multi) do
      {:ok, %{publish_rev: %Revision{formula: formula}}} ->
        {:ok, formula}

      {:error, :new_formula, changeset, _changes_so_far} ->
        {:error, changeset}

      {:error, :publish_rev, changeset, _changes_so_far} ->
        {:error, changeset}
    end
  end

  @doc """
  Updates a formula.

  ## Examples

      iex> update_formula(formula, %{field: new_value}, user)
      {:ok, %Formula{}}

      iex> update_formula(formula, %{field: bad_value}, user)
      {:error, %Ecto.Changeset{}}

  """
  def update_formula(%Formula{} = formula, attrs, user) do
    formula
    |> Ecto.build_assoc(:revisions, user: user, syntax: formula.syntax)
    |> Revision.creating_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Deletes a formula.

  ## Examples

      iex> delete_formula(formula)
      {:ok, %Formula{}}

      iex> delete_formula(formula)
      {:error, %Ecto.Changeset{}}

  """
  def delete_formula(%Formula{} = formula) do
    Repo.delete(formula)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking formula changes.

  ## Examples

      iex> change_formula(formula)
      %Ecto.Changeset{data: %Formula{}}

  """
  def change_formula(formula, attrs \\ %{}, action \\ :edit)

  def change_formula(%Formula{} = formula, attrs, :edit) do
    rev = %Revision{
      formula: formula,
      code: formula.code,
      syntax: formula.syntax
    }

    Revision.creating_changeset(rev, attrs)
  end

  def change_formula(%Formula{} = formula, attrs, :new) do
    Formula.creating_changeset(formula, attrs)
  end

  def subscribe(event) do
    Phoenix.PubSub.subscribe(Formular.Server.PubSub, event)
  end

  def broadcast({:ok, %Formula{} = ret}, topic) do
    ret = compile(ret)
    to_broadcast = %{ret | code: ret.compiled_code}

    do_broadcast(topic, {:update, to_broadcast})
    {:ok, ret}
  end

  def broadcast({:ok, %Revision{formula: %Formula{} = formula} = ret}, topic) do
    formula = compile(formula)
    to_broadcast = %{formula | code: formula.compiled_code}

    do_broadcast(topic, {:update, to_broadcast})
    {:ok, ret}
  end

  def broadcast(other, _) do
    other
  end

  defp do_broadcast(topic, msg) do
    Phoenix.PubSub.broadcast(
      Formular.Server.PubSub,
      topic,
      msg
    )
  end

  @spec get_revision!(integer()) :: Ecto.Schema.t()
  def get_revision!(id) do
    Repo.get!(Revision, id)
  end

  @spec new_revision(formula(), User.t(), map()) :: Ecto.Changeset.t()
  def new_revision(%Formula{} = formula, user, attrs) do
    formula
    |> Ecto.build_assoc(:revisions, user: user, syntax: formula.syntax)
    |> Revision.creating_changeset(attrs)
  end

  @spec create_revision(formula(), User.t(), map()) :: {:ok, Ecto.Schema.t()} | {:error, term()}
  def create_revision(%Formula{} = formula, user, attrs) do
    formula
    |> Ecto.build_assoc(:revisions, user: user, syntax: formula.syntax)
    |> Revision.creating_changeset(attrs)
    |> Repo.insert()
  end

  @spec publish_revision(Ecto.Schema.t()) :: {:ok, Ecto.Schema.t()} | {:error, term()}
  def publish_revision(revision) do
    Revision.publishing_changeset(revision)
    |> Repo.update()
    |> broadcast("formula:#{revision.formula_id}")
  end

  def change_revision(rev, attrs) do
    Revision.changing_changeset(rev, attrs)
  end

  def update_revision(rev, attrs) do
    Revision.changing_changeset(rev, attrs)
    |> Repo.update()
  end

  def online?(formula_name) do
    online_consumers(formula_name) != []
  end

  def online_consumers(formula_name) do
    consumers =
      Phoenix.Tracker.list(
        Formular.Server.Tracker,
        topic(formula_name)
      )

    for {%{client_name: consumer}, _} <- consumers, into: MapSet.new(), do: consumer
  end

  defp topic(formula_name), do: "formula:#{formula_name}"

  @doc """
  Run a formula by name and input arguments.
  """
  @spec run(binary(), map()) :: {:ok, any()} | {:error, any()}
  def run(formula_name, %{} = args) do
    with {:ok, formula} <- get_formula_by_name(formula_name, compile: true) do
      compute(formula, args)
    end
  end

  defp compute(formula, input) do
    Formular.Server.InstantCompute.compute(formula, input)
  end

  @doc """
  Compile a formula to Elixir code.
  """
  @spec compile(Formula.t()) :: Formula.t()
  def compile(%Formula{syntax: "Decision Table"} = formula) do
    %{formula | compiled_code: Tablex.CodeGenerate.generate(formula.code)}
  end

  def compile(%Formula{} = formula) do
    %{formula | compiled_code: formula.code}
  end

  @doc """
  Given a formula and input data, return all matched rules, including those
  that will not be executed.
  """
  def get_rules(%Formula{code: code}, input) do
    table = Tablex.new(code)
    input = Atomify.to_atom_keys(input)

    Tablex.Rules.get_rules(table, input)
  end

  @doc """
  Update or insert a rule for a formula.
  """
  def update_rule_by_input(%Formula{code: code} = formula, input, output, user) do
    input = Atomify.to_atom_keys(input)
    output = Atomify.to_atom_keys(output)

    Logger.info("Updating rule #{inspect(input)}, #{inspect(output)}")

    new_code =
      code
      |> Tablex.new()
      |> Tablex.Rules.update_rule_by_input(input, output)
      |> Tablex.Formatter.to_s()

    update_formula(formula, %{code: new_code}, user)
  end

  @doc """
  Update or insert a rule for a formula.
  """
  def update_rule_by_id(%Formula{code: code} = formula, id, output, user) do
    output = Atomify.to_atom_keys(output)

    Logger.info("Updating rule #{id}, #{inspect(output)}")

    new_code =
      code
      |> Tablex.new()
      |> Tablex.Rules.update_rule(id, output: output)
      |> Tablex.Formatter.to_s()

    update_formula(formula, %{code: new_code}, user)
  end

  @doc """
  Fuzzy search for formulas by a term.
  """
  def search_formulas(term) do
    query =
      from(Formula)
      |> where(fragment("similarity(name, ?) > 0 OR similarity(code, ?) > 0", ^term, ^term))
      |> order_by([q],
        desc: fragment("similarity(name, ?) * 2 + similarity(code, ?)", ^term, ^term)
      )

    Repo.all(query)
  end
end
