defmodule Formular.ServerWeb.UserOauthController do
  use Formular.ServerWeb, :controller

  alias Formular.Server.Accounts
  alias Formular.ServerWeb.UserAuth

  plug Ueberauth
  require Logger

  @rand_pass_length 32
  @support_oauth_providers Application.compile_env(:formular_server, :oauth_strategies, [])

  def callback(%{assigns: %{ueberauth_auth: %{info: user_info}}} = conn, %{"provider" => provider})
      when provider in @support_oauth_providers do
    Logger.info(["Got user info from #{provider}: ", inspect(user_info)])

    user_params = %{email: user_info.email, password: random_password()}

    with :ok <- Accounts.validate_by_provider(provider, user_info),
         {:ok, user} <- Accounts.fetch_or_create_user(user_params) do
      UserAuth.log_in_user(conn, user)
    else
      {:error, {:invalid_auth, msg}} ->
        Logger.warning("Authentication failed: #{msg}")

        conn
        |> put_flash(:error, "Authentication failed: #{msg}")
        |> redirect(to: Routes.user_session_path(conn, :new))

      err ->
        Logger.warning("Authentication failed: #{inspect(err)}")

        conn
        |> put_flash(:error, "Authentication failed")
        |> redirect(to: Routes.user_session_path(conn, :new))
    end
  end

  def callback(conn, _params) do
    conn
    |> put_flash(:error, "Authentication failed")
    |> redirect(to: "/")
  end

  defp random_password,
    do: :crypto.strong_rand_bytes(@rand_pass_length) |> Base.encode64()
end
