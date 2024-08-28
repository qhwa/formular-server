defmodule Formular.Server.Repo do
  use Ecto.Repo,
    otp_app: :formular_server,
    adapter: Ecto.Adapters.Postgres
end
