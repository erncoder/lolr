defmodule Lolr.Clients.RiotTest do
  @moduledoc """
  Note: this test relies on the MockMe package a co-worker's project that doesn't allow for dynamic responses, yet
  """

  use ExUnit.Case

  alias Lolr.Clients.Riot, as: TestMe
  alias Lolr.Models.Summoner

  @moduletag :clients

  @all_regions ["BR1", "EUN1", "EUW1", "JP1", "KR", "LA1", "LA2", "NA1", "OC1", "RU", "TR1"]
  @america_regions ["BR1", "LA1", "LA2", "NA1", "OC1"]
  @asia_regions ["KR", "JP1"]
  @euro_regions ["EUN1", "EUW1", "RU", "TR1"]

  setup_all %{} do
    MockMe.reset_flags()
  end

  describe "get_summoner_by_name/2" do
    test "returns an ok tuple with a summoner struct if summoner exists and is in a valid region" do
      MockMe.set_response(:fetch_summoner, :success)
      region = TestMe.fetch_all_regions() |> Enum.random()
      assert {:ok, %Summoner{}} = TestMe.get_summoner_by_name(region, "Bob")
    end

    test "returns an ok tuple with nil if summoner doesn't exist in valid region" do
      MockMe.set_response(:fetch_summoner, :not_found)
      region = TestMe.fetch_all_regions() |> Enum.random()
      assert {:ok, nil} = TestMe.get_summoner_by_name(region, "Bob")
    end

    test "returns an error tuple if the region is invalid" do
      MockMe.set_response(:fetch_summoner, :success)

      assert {:error, "can't get summoner: invalid region (\"INV\"" <> _} = TestMe.get_summoner_by_name("INV", "Bob")
    end

    test "returns a warn tuple if the token is rate limited" do
      MockMe.set_response(:fetch_summoner, :rate_limited)
      region = TestMe.fetch_all_regions() |> Enum.random()
      assert {:warn, :rate_limited} = TestMe.get_summoner_by_name(region, "Bob")
    end
  end

  describe "get_match_history_by_puuid/4" do
    test "returns an ok tuple with a list of 5 uuids if the puuid and region are valid" do
      MockMe.set_response(:match_list, :success)
      {:ok, region} = TestMe.fetch_all_regions() |> Enum.random() |> TestMe.generalize_region()
      assert {:ok, match_ids} = TestMe.get_match_history_by_puuid(region, "puuid", 5)
      assert is_list(match_ids)
      assert length(match_ids) == 5
    end

    test "returns an ok tuple with nil if summoner doesn't exist in valid region" do
      MockMe.set_response(:match_list, :not_found)
      {:ok, region} = TestMe.fetch_all_regions() |> Enum.random() |> TestMe.generalize_region()
      assert {:ok, nil} = TestMe.get_match_history_by_puuid(region, "puuid", 5)
    end

    test "returns an error tuple if the region is invalid" do
      MockMe.set_response(:match_list, :success)

      assert {:error, "can't get match history: invalid region (\"INV\"" <> _} =
               TestMe.get_match_history_by_puuid("INV", "puuid", 5)
    end

    test "returns a warn tuple if the token is rate limited" do
      MockMe.set_response(:match_list, :rate_limited)
      {:ok, region} = TestMe.fetch_all_regions() |> Enum.random() |> TestMe.generalize_region()
      assert {:warn, :rate_limited} = TestMe.get_match_history_by_puuid(region, "puuid", 5)
    end
  end

  describe "get_match_details/2" do
    test "returns an ok tuple with a map if match_id and region are valid" do
      MockMe.set_response(:match_details, :success)
      {:ok, region} = TestMe.fetch_all_regions() |> Enum.random() |> TestMe.generalize_region()
      assert {:ok, %{"info" => %{"participants" => participants}}} = TestMe.get_match_details(region, Faker.UUID.v4())
      assert is_list(participants)
      assert length(participants) == 10
    end

    test "returns an ok tuple with nil if match_id doesn't exist in valid region" do
      MockMe.set_response(:match_details, :not_found)
      {:ok, region} = TestMe.fetch_all_regions() |> Enum.random() |> TestMe.generalize_region()
      assert {:ok, nil} = TestMe.get_match_details(region, Faker.UUID.v4())
    end

    test "returns an error tuple if the region is invalid" do
      MockMe.set_response(:match_details, :success)

      assert {:error, "can't get match details: invalid region (\"INV\"" <> _} =
               TestMe.get_match_details("INV", Faker.UUID.v4())
    end

    test "returns a warn tuple if the token is rate limited" do
      MockMe.set_response(:match_details, :rate_limited)
      {:ok, region} = TestMe.fetch_all_regions() |> Enum.random() |> TestMe.generalize_region()
      assert {:warn, :rate_limited} = TestMe.get_match_details(region, Faker.UUID.v4())
    end
  end

  test "fetch_all_regions/0" do
    assert @all_regions = TestMe.fetch_all_regions()
  end

  describe "generalize_region/1" do
    test "returns ok tuple with `AMERICAS` if in America" do
      region = Enum.random(@america_regions)
      assert {:ok, "AMERICAS"} = TestMe.generalize_region(region)
    end

    test "returns ok tuple with `ASIA` if in Asia" do
      region = Enum.random(@asia_regions)
      assert {:ok, "ASIA"} = TestMe.generalize_region(region)
    end

    test "returns ok tuple with `EUROPE` if in Europe" do
      region = Enum.random(@euro_regions)
      assert {:ok, "EUROPE"} = TestMe.generalize_region(region)
    end

    test "returns error tuple if region is unknown" do
      region = Faker.Address.country_code()
      assert {:error, "unknown region" <> _rem} = TestMe.generalize_region(region)
    end
  end
end
