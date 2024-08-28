defmodule SignInUser do
  @moduledoc """
  This module is used to sign in a user.
  """

  import Formular.Server.Factory, only: [insert: 1]
  import Plug.Conn, only: [put_req_header: 3]

  def sign_in_user(%{conn: conn}) do
    user = insert(:user)
    token = Formular.Server.Accounts.create_user_api_token(user)

    {:ok,
     user: user, api_token: token, conn: put_req_header(conn, "authorization", "Bearer " <> token)}
  end
end
