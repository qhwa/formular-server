defmodule Formular.ServerWeb.Api.RevisionController do
  alias Formular.Server.Formulas

  use Formular.ServerWeb, :controller

  action_fallback :fallback

  def create(conn, %{"formula_name" => name, "code" => %Plug.Upload{path: path}} = params) do
    params =
      params
      |> Map.update!("code", fn _ -> File.read!(path) end)
      |> Map.take(["code", "note"])

    with {:ok, _rev} <- create_rev(name, params, conn.assigns.current_user) do
      json(conn, %{success: true})
    end
  end

  def create(conn, %{"formula_name" => name, "code" => "" <> _} = params) do
    params =
      params
      |> Map.take(["code", "note"])

    with {:ok, _rev} <- create_rev(name, params, conn.assigns.current_user) do
      json(conn, %{success: true})
    end
  end

  def create(conn, _params) do
    conn
    |> put_status(400)
    |> json(%{success: false, message: "Invalid parameters"})
  end

  defp create_rev(name, params, user) do
    with {:ok, formula} <- Formulas.get_formula_by_name(name),
         {:ok, rev} <- do_create_revision(formula, params, user),
         {:ok, _rev} <- Formulas.publish_revision(%{rev | formula: formula}) do
      {:ok, rev}
    end
  rescue
    e in SyntaxError ->
      {:error, e.description}
  end

  defp do_create_revision(formula, params, user) do
    Formulas.create_revision(formula, user, params)
  end

  defp fallback(conn, {:error, reason}) do
    conn
    |> put_status(400)
    |> json(%{success: false, message: inspect(reason)})
  end
end
