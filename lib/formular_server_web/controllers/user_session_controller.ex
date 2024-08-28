defmodule Formular.ServerWeb.UserSessionController do
  use Formular.ServerWeb, :controller

  alias Formular.Server.Accounts
  alias Formular.ServerWeb.UserAuth

  @oauth_strategies Application.compile_env(:formular_server, :oauth_strategies, [])

  def new(conn, _params) do
    case @oauth_strategies do
      [strategy] ->
        redirect(conn, to: Routes.user_oauth_path(conn, :request, strategy))

      _ ->
        render(conn, "new.html", error_message: nil, oauth_strategies: @oauth_strategies)
    end
  end

  def create(conn, %{"user" => user_params}) do
    %{"email" => email, "password" => password} = user_params

    if user = Accounts.get_user_by_email_and_password(email, password) do
      UserAuth.log_in_user(conn, user, user_params)
    else
      # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
      render(conn, "new.html", error_message: "Invalid email or password")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> UserAuth.log_out_user()
  end
end
