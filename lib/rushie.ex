defmodule Rushie do
  @moduledoc """
  API for Rushie
  """

  alias Rushie.FileMeta
  alias Rushie.Login
  alias Rushie.ManagedShare

  @doc """
  Login to Rushfiles. You need to login before you can actually do anything
  with Rushie. Most other Rushie functions need a login struct as first argument.
  """
  @spec login(domain :: String.t, email :: String.t, password :: String.t) :: {:ok, Login.t} | {:error, any}
  def login(domain, email, password) do
    with {:ok, login} <- Login.login(domain, email, password) do
      Login.gateway_login(login)
    end
  end

  @doc """
  Upload a file to a Rushfiles share
  """
  @spec upload_file(login :: Login.t, share :: ManagedShare.t, file_path :: String.t) :: {:ok, FileMeta.t} | {:error, any}
  def upload_file(%Login{} = login, %ManagedShare{} = share, file_path, target_filename \\ nil) do
    with {:ok, data} <- File.read(file_path),
         file_name <- target_filename || Path.basename(file_path),
         {:ok, :put, url} <- file_event(login, 0, share, {file_name, data}) do
      put_file(login, url, data)
    end
  end

  @doc """
  List all files in a Rushfiles share
  """
  @spec list_files(login :: Login.t, share :: ManagedShare.t) :: {:ok, [FileMeta.t]} | {:error, any}
  def list_files(%Login{} = login, %ManagedShare{} = share) do
    url = "https://clientgateway.#{login.domain}/api/shares/#{share.share_id}/children"
    headers = ["Authorization": "DomainToken #{login.token}"]

    case HTTPoison.get(url, headers, httpoison_options()) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        parse_list_response(body)
      other ->
        {:error, {__MODULE__, :list_files, other}}
    end
  end

  @doc """
  Download a specific file from a Rushfile share.
  `local_file` is the full path to write the file locally.
  """
  @spec download_file(login :: Login.t, share :: ManagedShare.t, file :: FileMeta.t, local_file :: String.t) :: :ok | {:error, any}
  def download_file(%Login{} = login, %ManagedShare{} = share, %FileMeta{} = file, local_file) do
    file_cache_url = List.first(login.file_cache_urls)
    headers = ["Authorization": "DomainToken #{login.token}"]
    url = "https://#{file_cache_url}/api/shares/#{share.share_id}/files/#{file.upload_name}"

    case HTTPoison.get(url, headers, httpoison_options()) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        File.write(local_file, body)
      other -> {:error, {__MODULE__, :get_file, other}}
    end
  end

  @doc """
  Internal.

  event_type: 0 = create
  """
  def file_event(%Login{} = login, event_type, %ManagedShare{} = share, file_data) do
    file_cache_url = List.first(login.file_cache_urls)
    headers = ["Content-type": "application/json", "Authorization": "DomainToken #{login.token}"]
    utc_now = DateTime.to_unix(DateTime.utc_now(), :milliseconds)
    url = "https://#{file_cache_url}/api/shares/#{share.share_id}/files"

    body = %{
     "TransmitId" => "rushieguid_" <> to_string(utc_now),
     # "UserOrigin" => login.email,
     "ClientJournalEventType" => event_type,
     # "TransmitDate" => utc_now,
     "RfVirtualFile" => rf_virtual_file(share, file_data),
     # "ShareToken" => share.acl_token,
     "DeviceId" => "test_device_id"
   }

    case HTTPoison.post(url, Poison.encode!(body), headers, httpoison_options()) do
      {:ok, %HTTPoison.Response{status_code: 202, body: body}} ->
        parse_file_event(body)
      other -> {:error, {__MODULE__, :file_event, other}}
    end
  end

  def put_file(%Login{} = login, url, data) do
    data_size = byte_size(data)
    headers = [
      "Authorization": "DomainToken #{login.token}",
      "Content-Range": "bytes 0-#{data_size - 1}/#{data_size}"
    ]

    case HTTPoison.put(url, data, headers, httpoison_options()) do
      {:ok, %HTTPoison.Response{status_code: 201, body: body}} ->
        parse_put_file(body)
      other -> {:error, {__MODULE__, :put_file, other}}
    end
  end

  def parse_file_event(body) do
    with {:ok, value} <- Poison.decode(body) do
      {:ok, :put, get_in(value, ["Data", "Url"])}
    end
  end

  def parse_put_file(body) do
    with {:ok, value} <- Poison.decode(body),
         1 <- get_in(value, ["Code"]) do
      meta = value
      |> get_in(["Data", "ClientJournalEvent", "RfVirtualFile"])
      |> FileMeta.parse_file_meta()

      {:ok, meta}
    else
      value when is_number(value) ->
        {:error, {__MODULE__, :parse_put_response, "Unexpected Code: #{value}"}}
      other -> other
    end
  end

  defp rf_virtual_file(%ManagedShare{} = share, {file_name, file_data}) do
    now = DateTime.utc_now()
    %{
      "InternalName" => file_name,
      # "Tick" => 1,
      "ShareId" => share.share_id,
      # "ShareTick" => 1,
      "ParrentId" => share.share_id,
      "EndOfFile" => byte_size(file_data),
      "PublicName" => file_name,
      "CreationTime" => DateTime.to_iso8601(now),
      "LastAccessTime" => DateTime.to_iso8601(now),
      "LastWriteTime" => DateTime.to_iso8601(now),
      "Attributes" => 128,
      # "Deleted" => false,
      "FilehHash" => Base.encode16(:erlang.md5(file_data), case: :lower)
    }
  end

  def parse_list_response(body) do
    with {:ok, value} <- Poison.decode(body) do
      metas = Enum.map(get_in(value, ["Data"]) || [], &FileMeta.parse_file_meta/1)
      {:ok, metas}
    end
  end

  def httpoison_options do
    [
      timeout: :timer.seconds(50),
      recv_timeout: :timer.minutes(5)
    ]
  end
end
