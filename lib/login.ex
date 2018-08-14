defmodule Rushie.Login do
  @moduledoc """
  Functionality to login to a Rushfiles instance
  """

  alias Rushie.ManagedShare

  defstruct token: "",
            email: "",
            domain: "",
            managed_shares: [],
            file_cache_urls: []

  @login_url_prefix (Application.get_env(:rushie, :login_url_prefix) || "https://clientgateway.")

  @doc """
  Login to the specified domain with email, password.
  It's not recommended to call this function directly, instead use `Rushie.login/3`
  """
  def login(domain, email, password) do
    url = @login_url_prefix <> "#{domain}/Login2.aspx"
    headers = [
      useremail: email,
      password2: Base.encode64(password),
      deviceid: "",
      devicename: "rushie",
      devicetype: "WebClient",
      deviceos: "",
      ip: "127.0.0.1" # TODO replace w real one?
    ]

    case HTTPoison.get(url, headers, Rushie.httpoison_options()) do
      {:ok, %HTTPoison.Response{body: body, status_code: 200}} ->
        parse_login(body)
      other -> {:error, {__MODULE__, :login, other}}
    end
  end

  @doc """
  Login to a Rushfiles gateway.
  It's not recommended to call this function directly, instead use `Rushie.login/3`
  """
  def gateway_login(%__MODULE__{} = login) do
    url = @login_url_prefix <> "#{login.domain}/ClientLogin.aspx?userEmail=#{login.email}&token=#{login.token}"
    case HTTPoison.get(url, [], Rushie.httpoison_options()) do
      {:ok, %HTTPoison.Response{body: body, status_code: 200}} ->
        parse_gateway_login(login, body)
      other -> {:error, {__MODULE__, :gateway_login, other}}
    end
  end

  def parse_login(body) do
    with {:ok, parsed} <- Jason.decode(body) do
      {:ok, %__MODULE__{
        domain: get_in(parsed, ["PrimaryUserDomain", "Domain", "Url"]),
        token: get_in(parsed, ["PrimaryUserDomain", "UserDomainToken"]),
        email: get_in(parsed, ["User", "Email"])}
      }
    end
  end

  def parse_gateway_login(login, body) do
    with {:ok, parsed} <- Jason.decode(body) do
      shares = Enum.map(parsed["ManagedShares"] || [], &ManagedShare.parse_managed_share/1)
      file_cache_urls = get_in(parsed, ["FilecacheUrls"]) || []
      {:ok, %__MODULE__{login |
        managed_shares: shares,
        file_cache_urls: file_cache_urls
      }}
    end
  end
end
