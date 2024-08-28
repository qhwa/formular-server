defmodule Formular.ServerWeb.UserSettingsView do
  alias Formular.Server.Accounts.User

  use Formular.ServerWeb, :view

  import Phoenix.HTML.Form

  def display_name(nil),
    do: "--"

  def display_name(%User{first_name: first_name} = user) when not is_nil(first_name),
    do: name(user)

  def display_name(%User{email: email}),
    do: email

  defp name(%User{first_name: first_name, middle_name: middle_name, last_name: last_name}) do
    [first_name, middle_name, last_name]
    |> Stream.reject(&is_nil/1)
    |> Stream.map(&String.trim/1)
    |> Stream.reject(&(&1 == ""))
    |> Enum.join(" ")
  end
end
