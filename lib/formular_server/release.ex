defmodule Formular.Server.Release do
  @moduledoc """
  This modules handles migrations for both the main database and event store database.

  ## Running in production

  ```sh
  $bin/formular_server eval 'Formular.Server.Release.migrate'
  ```
  """

  require Logger

  @app :formular_server

  @spec migrate :: :ok
  def migrate do
    load_app()

    for repo <- main_repos() do
      ret = repo.__adapter__.storage_up(repo.config)

      unless ret in [:ok, {:error, :already_up}], do: raise(ret)

      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end

    :ok
  end

  @doc """
  Rollback migrations for specified ecto repo.

  ## Running in production

  ```sh
  $bin/wally eval 'Wally.Release.rollback(Wally.Repo)'
  ```

  Be default, only one step is rolled back. You can specify how many steps like:

  ```sh
  $bin/wally eval 'Wally.Release.rollback(Wally.Repo, 2)'
  ```
  """
  @spec rollback(Ecto.Repo.t(), pos_integer) :: :ok

  def rollback(repo, step \\ 1) do
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, step: step))
    :ok
  end

  defp load_app, do: Application.load(@app)
  defp main_repos, do: Application.fetch_env!(@app, :ecto_repos)
end
