defmodule Rushie.FileMeta do
  @moduledoc """
  Represents metadata for a file in Rushfiles
  """

  defstruct upload_name: "",
            user: "",
            subshare?: false,
            file?: false,
            internal_name: "",
            share_id: "",
            sub_share_ids: [],
            tick: 0,
            share_tick: 0,
            parent_id: "",
            file_size: 0,
            public_name: "",
            creation_time: "",
            last_access_time: "",
            last_write_time: "",
            attributes: 0,
            deleted?: false

  @doc """
  Parse a RfVirtualFile object from Rushfiles
  """
  def parse_file_meta(file_map) do
    %__MODULE__{
      upload_name: get_in(file_map, ["UploadName"]),
      user: get_in(file_map, ["User"]),
      subshare?: get_in(file_map, ["IsSubshare"]),
      file?: get_in(file_map, ["IsFile"]),
      internal_name: get_in(file_map, ["InternalName"]),
      share_id: get_in(file_map, ["ShareId"]),
      sub_share_ids: get_in(file_map, ["SubShareIds"]),
      tick: get_in(file_map, ["Tick"]),
      share_tick: get_in(file_map, ["ShareTick"]),
      parent_id: get_in(file_map, ["ParrentId"]),
      file_size: get_in(file_map, ["EndOfFile"]),
      public_name: get_in(file_map, ["PublicName"]),
      creation_time: get_in(file_map, ["CreationTime"]),
      last_access_time: get_in(file_map, ["LastAccessTime"]),
      last_write_time: get_in(file_map, ["LastWriteTime"]),
      attributes: get_in(file_map, ["Attributes"]),
      deleted?: get_in(file_map, ["Deleted"])
    }
  end
end
