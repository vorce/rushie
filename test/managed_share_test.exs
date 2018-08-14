defmodule Rushie.ManagedShareTest do
  use ExUnit.Case

  alias Rushie.ManagedShare

  @gateway_response File.read!("test/data/gateway_login_response.json")

  describe "parse_managed_share/1" do
    test "returns a ManagedShare struct" do
      raw_managed_shares = Jason.decode!(@gateway_response)["ManagedShares"]
      first_raw_share = List.first(raw_managed_shares)

      assert ManagedShare.parse_managed_share(first_raw_share) == %Rushie.ManagedShare{
        full?: false,
        id: "",
        acl_token: "Z",
        name: "backup",
        owner: "person@place.com",
        share_id: "cb6349efa"
      }
    end
  end
end
