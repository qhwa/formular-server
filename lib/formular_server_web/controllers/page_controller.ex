defmodule Formular.ServerWeb.PageController do
  use Formular.ServerWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
