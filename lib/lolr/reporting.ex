defmodule Lolr.Reporting do
  @moduledoc """
  Context housing the logic to handle calls to start reporting for a summoner, as well as to manage Reporter GenServers
  """

  alias Lolr.Clients.Riot
  alias Lolr.Models.Summoner

  alias Lolr.Reporting.Supervisor, as: ReportingSupervisor
  alias Lolr.Reporting.Worker

  require Logger

  def start(region, summoner_name) do
    with {"conform region", c_region} <-
           {"conform region", conform_region(region)},
         {"validate region", true} <-
           {"validate region", validate_region(c_region)},
         {"get riot data", {:ok, _summoner, others} = riot_data} <-
           {"get riot data", get_riot_data(c_region, summoner_name)},
         {"start Reporter", {:ok, _pid}} <-
           {"start Reporter", start_reporter(c_region, riot_data)} do
      other_names = others |> Enum.map(fn %Summoner{name: name} -> name end)
      {:ok, other_names}
    else
      {step, result} ->
        Logger.error(
          "start failed for summoner #{summoner_name} in region #{region} on step #{step} with result #{inspect(result)}"
        )

        {:error, "internal error 1"}
    end
  end

  #
  # MAIN FXNS
  #

  def get_riot_data(region, summoner_name) do
    with {"get summoner", {:ok, %Summoner{puuid: puuid} = summoner}} <-
           {"get summoner", Riot.get_summoner_by_name(region, summoner_name)},
         {"generalize region", {:ok, g_region}} <-
           {"generalize region", generalize_region(region)},
         {"get last matches", {:ok, match_ids}} <-
           {"get last matches", Riot.get_match_history_by_puuid(g_region, puuid, 5)} do
      other_summoners = get_other_summoners(g_region, match_ids, summoner_name)
      {:ok, summoner, other_summoners}
    else
      fail_tuple -> fail_tuple
    end
  end

  def get_other_summoners(region, match_ids, primary_name) do
    match_ids
    |> Enum.map(fn match_id ->
      case Riot.get_match_details(region, match_id) do
        {:ok, %{"info" => %{"participants" => participants}}} ->
          process_participants(participants, primary_name)

        _ ->
          []
      end
    end)
    |> List.flatten()
  end

  def process_participants(participants, primary_name) do
    participants
    |> Enum.map(fn %{"puuid" => puuid, "summonerName" => name} ->
      if name != primary_name do
        %Summoner{name: name, puuid: puuid}
      else
        []
      end
    end)
  end

  def start_reporter(region, {:ok, %Summoner{name: name} = primary, others}) do
    all_summoners = [primary | others]
    {:ok, g_region} = generalize_region(region)

    DynamicSupervisor.start_child(
      ReportingSupervisor,
      {Worker, [name: name, region: g_region, summoners: all_summoners]}
    )
  end

  #
  # HELPER FXNS
  #

  def conform_region(region), do: region |> String.upcase()
  def validate_region(region), do: region in Riot.fetch_all_regions()
  def generalize_region(region), do: Riot.generalize_region(region)
end
