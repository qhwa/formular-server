defmodule Formular.Server.Util.Atomify do
  @moduledoc """
  This module is used to atomify, turning string keys to atoms of, the input.
  """
  def to_atom_keys(%{} = input) do
    Map.new(input, fn
      {"" <> k, v} -> {to_existing_atom(k), to_atom_keys(v)}
      {k, v} -> {k, to_atom_keys(v)}
    end)
  end

  def to_atom_keys(otherwise), do: otherwise

  defp to_existing_atom(str) do
    String.to_existing_atom(str)
  rescue
    ArgumentError -> str
  end
end
