defmodule RidexWeb.AuthenticationControllerTest do
  use RidexWeb.ConnCase

  describe "POST /api/authenticate" do
    test "returns OK with token", %{conn: conn} do
      body =
        conn
        |> post("/api/authenticate", %{
          "phone" => "+165653757563",
          "type" => "rider"
        })
        |> json_response(200)

      %{
        "id" => user_id,
        "token" => token,
        "type" => "rider"
      } = body

      assert {:ok, _} = Ridex.Guardian.decode_and_verify(token, %{"sub" => user_id})
    end

    test "creates user", %{conn: conn} do
      body =
        conn
        |> post("/api/authenticate", %{
          "phone" => "+165653757568",
          "type" => "rider"
        })
        |> json_response(200)

      %{
        "id" => user_id
      } = body

      assert [%{id: new_user_id}] = Ridex.User |> Ridex.Repo.all()
      assert new_user_id == user_id
    end

    # test "returns 400 with wrong user type", %{conn: conn} do
    #   body =
    #     conn
    #     |> post("api/authenticate", %{
    #       "phone" => "165653757568",
    #       "type" => "driver"
    #     })
    #     |> json_response(200)

    #   %{
    #     "id" => user_id
    #   }
    # end
  end
end
