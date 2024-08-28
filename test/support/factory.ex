defmodule Formular.Server.Factory do
  @moduledoc false

  alias Formular.Server.Accounts.User
  alias Formular.Server.Formulas.Formula
  alias Formular.Server.Formulas.Revision

  use ExMachina.Ecto, repo: Formular.Server.Repo

  def user_factory do
    %User{
      first_name: sequence(:first_name, &"first_name-#{&1}"),
      email: sequence(:email, &"email-#{&1}@example.com"),
      hashed_password: "hashed_password"
    }
  end

  def formula_factory do
    %Formula{
      code: "123 + 7",
      name: sequence(:formula_name, &"f-#{&1}"),
      revisions: [build(:revision)]
    }
  end

  def revision_factory do
    %Revision{
      code: "123 + 7",
      user: build(:user)
    }
  end
end
