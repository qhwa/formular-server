defmodule Formular.ServerWeb.Api.ComputationControllerTest do
  use Formular.ServerWeb.ConnCase, async: true

  import Formular.Server.Factory
  import SignInUser

  describe "POST /api/run/:name" do
    setup [:sign_in_user]

    setup do
      %{formula: insert(:formula, code: "term")}
    end

    test "returns 400 when input argument is missing", %{formula: formula, conn: conn} do
      conn = post(conn, Routes.computation_path(conn, :create, formula))
      assert_failure("{:required, [:term]}", conn)
    end

    test "echos back a string", %{formula: formula, conn: conn} do
      conn =
        post(conn, Routes.computation_path(conn, :create, formula), %{
          "input" => %{
            "term" => "Hello, world!"
          }
        })

      assert_result("Hello, world!", conn)
    end

    test "echos back a map", %{formula: formula, conn: conn} do
      conn =
        post(conn, Routes.computation_path(conn, :create, formula), %{
          "input" => %{
            "term" => %{"value" => "a map"}
          }
        })

      assert_result(%{"value" => "a map"}, conn)
    end

    test "echos back a list", %{formula: formula, conn: conn} do
      conn =
        post(conn, Routes.computation_path(conn, :create, formula), %{
          "input" => %{
            "term" => [1, 2, 3]
          }
        })

      assert_result([1, 2, 3], conn)
    end

    test "returns error if atom not existing", %{formula: formula, conn: conn} do
      conn =
        post(conn, Routes.computation_path(conn, :create, formula), %{
          "input" => %{
            "term" => %{"@type" => "symbol", "@value" => "abc"}
          }
        })

      assert_failure(
        "%ArgumentError{message: \"errors were found at the given arguments:\\n\\n  * 1st argument: not an already existing atom\\n\"}",
        conn
      )
    end
  end

  describe "POST /api/run/:name with tuple transformation" do
    setup [:sign_in_user]

    setup do
      %{
        formula:
          insert(:formula,
            code: """
              case term do
                _ when is_tuple(term) ->
                  :tuple

                _ ->
                  :not_tuple
              end
            """
          )
      }
    end

    test "works with a tuple", %{formula: formula, conn: conn} do
      conn =
        post(conn, Routes.computation_path(conn, :create, formula), %{
          "input" => %{
            "term" => %{
              "@type" => "tuple",
              "@value" => [1, 2, 3]
            }
          }
        })

      assert_result("tuple", conn)
    end

    test "works with non-tuple", %{formula: formula, conn: conn} do
      conn =
        post(conn, Routes.computation_path(conn, :create, formula), %{
          "input" => %{
            "term" => [1, 2, 3]
          }
        })

      assert_result("not_tuple", conn)
    end
  end

  defp assert_failure(message, conn) do
    response = json_response(conn, 400)
    assert %{"success" => false, "message" => message} == response
  end

  defp assert_result(result, conn) do
    response = json_response(conn, 200)
    assert %{"result" => result, "success" => true} == response
  end
end
