defmodule Formular.ServerWeb.FormulaChannelTest do
  use Formular.ServerWeb.ChannelCase
  import Formular.Server.Factory

  setup do
    formula = insert(:formula)

    {:ok, _, socket} =
      Formular.ServerWeb.FormulaSocket
      |> socket("user_id", %{some: :assign})
      |> subscribe_and_join(Formular.ServerWeb.FormulaChannel, "formula:#{formula.name}")

    %{socket: socket}
  end

  test "ping replies with status ok", %{socket: socket} do
    ref = push(socket, "ping", %{"hello" => "there"})
    assert_reply ref, :ok, %{"hello" => "there"}
  end

  test "broadcasts are pushed to the client", %{socket: socket} do
    broadcast_from!(socket, "broadcast", %{"some" => "data"})
    assert_push "broadcast", %{"some" => "data"}
  end
end
