defmodule Rushie.ManagedShare do
  @moduledoc """
  Represents a ManagedShare in Rushfile.

  This struct is quite incomplete. But has enough
  for the current feature set of Rushie.

  To see the full details that is returned from the
  Rushie API, see: `gateway_login_response.json`.
  """

  defstruct name: "",
            owner: "",
            full?: false,
            share_id: "",
            acl_token: "",
            id: ""

  def parse_managed_share(share) when is_map(share) do
    %Rushie.ManagedShare{
      name: get_in(share, ["ShareName"]),
      owner: get_in(share, ["Owner"]),
      full?: get_in(share, ["StorageLimitReached"]),
      share_id: get_in(share, ["ShareAcl", "ShareId"]),
      acl_token: get_in(share, ["ShareAcl", "AclToken"])
    }
  end
end
