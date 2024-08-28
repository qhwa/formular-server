defmodule Formular.Core.Branch do
  @moduledoc """
  A logic branch with a matching condition and an expression.

  A branch can also have an ordering number which is used
  to determine which branch goes earlier than another on
  running the formula.
  """

  alias __MODULE__

  defstruct [:condition, :expression, order: 0]

  @type t() :: %Branch{
          condition: term(),
          expression: nil | Macro.t(),
          order: integer()
        }

  def compile(%Branch{condition: nil, expression: expr}) do
    {:->, [],
     [
       [true],
       expr
     ]}
  end

  def compile(%Branch{condition: {:match, pattern, variable}, expression: expr})
      when is_atom(variable) do
    {:->, [],
     [
       [
         {:match?, [context: Elixir, import: Kernel], [pattern, {variable, [], Elixir}]}
       ],
       expr
     ]}
  end
end
