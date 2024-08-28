defimpl Canada.Can, for: Formular.Server.Accounts.User do
  alias Formular.Server.Accounts.User
  alias Formular.Server.Formulas.Revision

  def can?(%User{}, :update_note, %Revision{user_id: nil}), do: true
  def can?(%User{id: user_id}, :update_note, %Revision{user_id: user_id}), do: true
  def can?(%User{}, :update_note, %Revision{}), do: false
end
