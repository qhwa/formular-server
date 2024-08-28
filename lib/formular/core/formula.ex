defmodule Formular.Core.Formula do
  @moduledoc """
  Formula struct 
  """

  alias __MODULE__
  alias Formular.Core.Branch

  defstruct name: nil, branches: []

  import Kernel, except: [to_string: 1]

  @type t() :: %Formula{
          name: String.t(),
          branches: [Formular.Core.Branch.t()]
        }

  @doc """
  Render the formula to formatted code string.
  """
  @spec to_formatted_string(t()) :: iodata()
  def to_formatted_string(%Formula{} = formula),
    do:
      formula
      |> to_string()
      |> Code.format_string!()

  @spec to_string(t()) :: String.t()
  def to_string(%Formula{} = formula),
    do:
      compile(formula)
      |> Macro.to_string()

  @spec compile(t()) :: Macro.t()
  def compile(%Formula{branches: branches}),
    do:
      branches
      |> Enum.sort_by(& &1.order, :desc)
      |> compile([])

  defp compile([], []),
    do: nil

  defp compile([], acc) do
    {:cond, [], [[do: acc]]}
  end

  defp compile([branch | rest], acc) do
    compile(rest, [Branch.compile(branch) | acc])
  end

  @doc """
  Check if a text is a piece of valid code.
  If it is, return the formatted code text.
  Otherwise, return `{:error, reason}`.
  """
  @spec to_formatted_code(String.t()) :: {:ok, iodata()} | {:error, term()}
  def to_formatted_code(text) do
    with {:ok, _} <- Code.string_to_quoted(text) do
      {:ok, Code.format_string!(text)}
    end
  end
end
