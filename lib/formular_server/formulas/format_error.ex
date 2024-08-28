defmodule Formular.Server.Formulas.FormatError do
  @moduledoc """
  Format error of the formula.
  """

  @derive Jason.Encoder
  defstruct [:pos, :msg, :current_word]
end
