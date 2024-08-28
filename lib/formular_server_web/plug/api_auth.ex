defmodule Formular.ServerWeb.Plug.ApiAuth do
  @moduledoc """
  This plug is used to authenticate API requests by checking the API token.
  """

  import Plug.Conn

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         %{} = user <- auth_api_token(token) do
      assign(conn, :current_user, user)
    else
      _ ->
        conn
        |> send_resp(403, "Unauthorized")
        |> halt()
    end
  end

  defp auth_api_token(token) do
    Formular.Server.Accounts.get_user_by_api_token(token)
  end
end
