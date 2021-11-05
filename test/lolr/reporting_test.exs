defmodule Lolr.ReportingTest do
  @moduledoc """
  Note: this test relies on the MockMe package a co-worker's project that doesn't allow for dynamic responses, yet
  """

  use ExUnit.Case

  alias Lolr.Reporting, as: TestMe
  alias Lolr.Models.Summoner

  @moduletag :reporting

  setup_all %{} do
    MockMe.reset_flags()
  end

  describe "start/2" do
    test "returns an ok tuple with list of 50 users if valid region and summoner_name" do
      MockMe.set_response(:fetch_summoner, :success)
      MockMe.set_response(:match_list, :success)
      MockMe.set_response(:match_details, :success)

      assert {:ok, other_names} = TestMe.start("NA1", "Bob")
      assert is_list(other_names)
      assert length(other_names) == 50
    end

    test "returns an ok tuple with message of no summoner exists in valid region" do
      MockMe.set_response(:fetch_summoner, :not_found)
      MockMe.set_response(:match_list, :success)
      MockMe.set_response(:match_details, :success)

      assert {:ok, "No summoner with that name" <> _rem} = TestMe.start("NA1", "Bob")
    end

    test "returns an error tuple with hidden implementation details if invalid region" do
      assert {:error, "internal error 1"} = TestMe.start("INV", "Bob")
    end

    test "returns an error tuple with hidden implementation details if bad api url" do
      MockMe.set_response(:fetch_summoner, :forbidden)
      assert {:error, "internal error 1"} = TestMe.start("NA1", "Bob")
    end

    test "returns an error tuple with hidden implementation details if rate limited" do
      MockMe.set_response(:fetch_summoner, :rate_limited)
      assert {:error, "internal error 1"} = TestMe.start("NA1", "Bob")
    end
  end

  describe "process_participants/2" do
    test "returns Summoner structs if given valid args" do
      participants = Test.Mocks.RiotApi.gen_participants()
      summoners = TestMe.process_participants(participants, "123")
      assert is_list(summoners)
      assert length(summoners) == 10
    end

    test "returns error tuple if given invalid args" do
      assert {:error, "non-conformant args"} = TestMe.process_participants(1, "123")
      assert {:error, "non-conformant args"} = TestMe.process_participants([], 1)
    end
  end

  test "start_reporter/2" do
    assert {:ok, _pid} = TestMe.start_reporter("NA1", {:ok, %Summoner{name: "Bob"}, []})
  end

  test "conform_region/1" do
    assert "USA" = TestMe.conform_region("usa")
    assert "USA" = TestMe.conform_region("uSa")
    assert "USA" = TestMe.conform_region("USa")
    assert "USA2" = TestMe.conform_region("USa2")
  end
end
