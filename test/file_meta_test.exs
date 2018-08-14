defmodule Rushie.FileMetaTest do
  use ExUnit.Case

  alias Rushie.FileMeta

  @list_response File.read!("test/data/share_children_response.json")

  describe "parse_file_meta/1" do
    test "returns FileMeta struct on list response" do
      list_raw = Jason.decode!(@list_response)["Data"]
      first_element = List.first(list_raw)

      assert FileMeta.parse_file_meta(first_element) == %Rushie.FileMeta{
               attributes: 32,
               creation_time: "2017-09-30T07:14:37.4282306Z",
               deleted?: false,
               file?: true,
               file_size: 13_678,
               internal_name: "85c30f31828d468ca5a27bb60102b66d",
               last_access_time: "2017-09-30T07:14:37.4282306Z",
               last_write_time: "2017-09-30T07:14:37.4282306Z",
               parent_id: "c8b3332ebdf0462f8b1a662f299e257a",
               public_name: "keepassx2db.kdbx",
               share_id: "c8b3332ebdf0462f8b1a662f299e257a",
               share_tick: 1,
               sub_share_ids: [],
               subshare?: false,
               tick: 1,
               upload_name: "54cde971333f45fd8ba1cb40154321f2",
               user: "person@place.com"
             }
    end

    @file_created_response File.read!("test/data/file_created_response.json")

    test "returns FileMeta struct on file created response" do
      struct =
        @file_created_response
        |> Jason.decode!()
        |> get_in(["Data", "ClientJournalEvent", "RfVirtualFile"])
        |> FileMeta.parse_file_meta()

      assert struct == %Rushie.FileMeta{
               attributes: 32,
               creation_time: "2017-10-03T12:12:07.320642Z",
               deleted?: false,
               file?: true,
               file_size: 13,
               internal_name: "test_internal_name",
               last_access_time: "2017-10-03T12:12:07.320642Z",
               last_write_time: "2017-10-03T12:12:07.320642Z",
               parent_id: "c8b3332ezzzz662f299e257a",
               public_name: "test_public_name",
               share_id: "czzz462f8b1a662f299e257a",
               share_tick: 2,
               sub_share_ids: [],
               subshare?: nil,
               tick: 1,
               upload_name: "de72d8yyyy92be62ee7d64",
               user: "person@place.com"
             }
    end
  end
end
