defmodule Rushie.LoginTest do
  use ExUnit.Case

  alias Rushie.Login

  setup do
    bypass = Bypass.open
    {:ok, bypass: bypass}
  end

  @login_success_response File.read!("test/data/login_response.json")

  describe "login/3" do
    test "returns login struct on success", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/Login2.aspx", fn conn ->
        Plug.Conn.resp(conn, 200, @login_success_response)
      end)
      login_response = Poison.decode!(@login_success_response)
      expected_return = %Rushie.Login{
        domain: get_in(login_response, ["PrimaryUserDomain", "Domain", "Url"]),
        email: get_in(login_response, ["User", "Email"]),
        token: get_in(login_response, ["PrimaryUserDomain", "UserDomainToken"])
      }

      assert Login.login("localhost:#{bypass.port}", "anyemail", "anypwd") ==
        {:ok, expected_return}
    end

    test "returns error tuple on failure", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/Login2.aspx", fn conn ->
        Plug.Conn.resp(conn, 500, ~s<{"errors": [{"code": 42, "message": "made up"}]}>)
      end)

      assert match?({:error, {Rushie.Login, :login, _}},
        Login.login("localhost:#{bypass.port}", "anyemail", "anypwd"))
    end
  end

  @gateway_login_success_response File.read!("test/data/gateway_login_response.json")

  describe "gateway_login/1" do
    test "returns login struct with more info on success", %{bypass: bypass} do
      login = %Rushie.Login{
        domain: "localhost:#{bypass.port}",
        email: "me@here.com",
        token: "token"
      }
      Bypass.expect_once(bypass, "GET", "/ClientLogin.aspx", fn conn ->
        Plug.Conn.resp(conn, 200, @gateway_login_success_response)
      end)
      response = Poison.decode!(@gateway_login_success_response)

      {code, login_result} = Login.gateway_login(login)

      assert code == :ok
      assert login_result.file_cache_urls == get_in(response, ["FilecacheUrls"])
      assert login_result.managed_shares != []
    end

    test "returns error tuple on failure", %{bypass: bypass} do
      login = %Rushie.Login{
        domain: "localhost:#{bypass.port}",
        email: "me@here.com",
        token: "token"
      }
      Bypass.expect_once(bypass, "GET", "/ClientLogin.aspx", fn conn ->
        Plug.Conn.resp(conn, 500, "Fail")
      end)

      assert match?({:error, {Rushie.Login, :gateway_login, _}},
        Login.gateway_login(login))
    end
  end
end
