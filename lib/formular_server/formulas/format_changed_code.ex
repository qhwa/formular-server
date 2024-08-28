defmodule Formular.Server.Formulas.FormatChangedCode do
  @moduledoc """
  A help module to validate and format code.
  """

  alias Formular.Core.Formula, as: Core
  alias Formular.Server.Formulas.FormatError

  import Ecto.Changeset

  def validate_code_format(changeset) do
    validate_code_format(changeset, syntax(changeset))
  end

  defp syntax(%{changes: %{syntax: syntax}}), do: syntax
  defp syntax(%{data: %{syntax: syntax}}), do: syntax

  @spec validate_code_format(Ecto.Changeset.t(), String.t()) :: Ecto.Changeset.t()
  def validate_code_format(%{changes: %{code: code}} = changeset, syntax) when is_binary(code) do
    case try_format(code, syntax) do
      {:ok, _} ->
        changeset

      {:error, error} ->
        changeset
        |> add_error(:code, "syntax error", format_error: error)
    end
  end

  def validate_code_format(changeset, _syntax) do
    changeset
  end

  defp try_format(code, "Decision Table") do
    code = String.trim(code)

    with %{} = table <- Tablex.new(code),
         table <- Tablex.Optimizer.optimize(table) do
      {:ok, Tablex.Formatter.to_s(table)}
    end
  end

  defp try_format(code, _) do
    case Core.to_formatted_code(code) do
      {:ok, code} ->
        {:ok, code}

      {:error, {pos, msg_info, cursor}} ->
        {:error,
         %FormatError{
           pos: Map.new(pos),
           msg: to_msg(msg_info),
           current_word: cursor
         }}
    end
  end

  defp to_msg({a, b}) when is_binary(a) and is_binary(b),
    do: a <> b

  defp to_msg(msg_info) when is_binary(msg_info),
    do: msg_info

  @spec validate_and_format_code(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  def validate_and_format_code(%{} = changeset) do
    validate_and_format_code(changeset, syntax(changeset))
  end

  @spec validate_and_format_code(Ecto.Changeset.t(), String.t()) :: Ecto.Changeset.t()
  def validate_and_format_code(%{changes: %{code: code}} = changeset, syntax)
      when is_binary(code) do
    case try_format(code, syntax) do
      {:ok, formatted_code} ->
        changeset
        |> change(%{code: formatted_code |> IO.iodata_to_binary()})

      {:error, error} ->
        changeset
        |> add_error(:code, "syntax error", format_error: error)
    end
  end

  def validate_and_format_code(changeset, _syntax) do
    changeset
  end
end
