defmodule Formular.Server.InstantCompute do
  @moduledoc """
  We can eval a formula with this module.
  """

  alias Formular.Server.Formulas.Formula

  @type formula :: Formula.t()

  @doc """
  Run a formula by name and input arguments.
  """
  @spec compute(formula(), map()) :: {:ok, any()} | {:error, any()}
  def compute(%Formula{code: code} = formula, %{} = args) do
    with {:ok, required_vars} <- args_valid?(args, formula),
         {:ok, input} <- compile_input(args, required_vars) do
      eval(code, input)
    end
  end

  defp args_valid?(args, %{code: code}) do
    required_vars = Formular.used_vars(code)

    required_vars
    |> Enum.reject(&Map.has_key?(args, &1))
    |> case do
      [] ->
        {:ok, required_vars}

      missing ->
        {:error, {:required, missing}}
    end
  end

  defp compile_input(%{} = args, required_vars) do
    {:ok,
     for var <- required_vars do
       {var, Map.get(args, var) |> json_to_term()}
     end}
  rescue
    e ->
      {:error, e}
  end

  defp json_to_term(%{"@value" => value, "@type" => type}) do
    json_to_term(value, type)
  end

  defp json_to_term(value) do
    value
  end

  defp json_to_term(value, "tuple") when is_list(value) do
    value |> Enum.map(&json_to_term/1) |> List.to_tuple()
  end

  defp json_to_term(value, "symbol") when is_binary(value) do
    value |> String.to_existing_atom()
  end

  defp eval(code, input) do
    Formular.eval(code, input, allow_modules: [List, Enum, Map, Stream])
  end
end
