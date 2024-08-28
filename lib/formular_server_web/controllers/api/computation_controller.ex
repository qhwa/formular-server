defmodule Formular.ServerWeb.Api.ComputationController do
  alias Formular.Server.Formulas
  alias Formular.Server.Util.Atomify

  use Formular.ServerWeb, :controller

  @create_schema %{
    "name" => :string,
    "input" => [:map, %{}, :not_required]
  }

  def create(conn, %{"name" => formular_name} = params) do
    with :ok <- validate_params(params),
         input <- Map.get(params, "input") || %{},
         {:ok, result} <- Formulas.run(formular_name, to_input(input)) do
      json(conn, %{success: true, result: result})
    else
      {:error, reason} ->
        conn
        |> put_status(400)
        |> json(%{success: false, message: inspect(reason)})
    end
  end

  defp validate_params(params) do
    params
    |> Skooma.valid?(@create_schema)
  end

  defp to_input(%{} = input) do
    Atomify.to_atom_keys(input)
  end
end

defimpl Jason.Encoder, for: Tuple do
  def encode(value, opts) do
    value
    |> Tuple.to_list()
    |> Jason.Encoder.encode(opts)
  end
end
