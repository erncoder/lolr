defmodule Lolr.Clients.Riot do
  @moduledoc """
  Client for the Riot API.
  """

  use HTTPoison.Base

  alias Lolr.Models.Summoner

  require Logger

  @all_regions ["BR1", "EUN1", "EUW1", "JP1", "KR", "LA1", "LA2", "NA1", "OC1", "RU", "TR1"]
  @america_regions ["BR1", "LA1", "LA2", "NA1", "OC1"]
  @asia_regions ["KR", "JP1"]
  @euro_regions ["EUN1", "EUW1", "RU", "TR1"]
  @general_regions ["AMERICAS", "ASIA", "EUROPE"]

  #
  # API Calls
  #

  def get_summoner_by_name(region, name)
      when is_binary(name) and region in @all_regions do
    build_summoner_url(region, name)
    |> get(get_headers())
    |> handle_response()
  end

  def get_summoner_by_name(region, name),
    do:
      handle_bad_call(
        "can't get summoner: invalid region (#{inspect(region)} or name (#{inspect(name)})"
      )

  def get_match_history_by_puuid(region, puuid, num_records, since_unix \\ 0)

  def get_match_history_by_puuid(region, puuid, num_records, since_unix)
      when is_binary(puuid) and
             region in @general_regions and
             is_integer(num_records) and
             is_integer(since_unix) do
    build_match_by_puuid_url(region, puuid)
    |> get(
      get_headers(),
      params: %{
        "count" => num_records,
        "startTime" => since_unix
      }
    )
    |> handle_response()
  end

  def get_match_history_by_puuid(region, puuid, _num_record, _since_unix),
    do:
      handle_bad_call(
        "can't get match history: invalid region (#{inspect(region)}) or puuid #{inspect(puuid)})"
      )

  def get_match_details(region, match_id)
      when is_binary(match_id) and
             region in @general_regions do
    build_match_by_id_url(region, match_id)
    |> get(get_headers())
    |> handle_response()
  end

  def get_match_details(region, match_id),
    do:
      handle_bad_call(
        "can't get match details: invalid region (#{inspect(region)}) or match_id (#{inspect(match_id)})"
      )

  #
  # REQUEST BUILDERS
  #

  defp get_headers() do
    %{
      "Accept-Language": "en-US,en;q=0.9",
      "Accept-Charset": "application/x-www-form-urlencoded; charset=UTF-8",
      "X-Riot-Token": api_key()
    }
  end

  defp build_summoner_url(region, name),
    do: "https://#{region}.api.riotgames.com/lol/summoner/v4/summoners/by-name/#{name}"

  defp build_match_by_puuid_url(region, puuid),
    do: "https://#{region}.api.riotgames.com/lol/match/v5/matches/by-puuid/#{puuid}/ids"

  defp build_match_by_id_url(region, match_id),
    do: "https://#{region}.api.riotgames.com/lol/match/v5/matches/#{match_id}"

  #
  # RESPONSE HANDLERS
  #

  def handle_response({:ok, %HTTPoison.Response{body: body, status_code: 200}}) do
    case Jason.decode(body) do
      {:ok, %{"name" => name, "puuid" => puuid}} ->
        {:ok, %Summoner{name: name, puuid: puuid, last_matches: []}}

      {:ok, _data} = resp ->
        resp

      {:error, err} ->
        handle_bad_call("#{inspect(err)}")
    end
  end

  def handle_response({:ok, %HTTPoison.Response{} = resp}, _region) do
    handle_bad_call("unhandled response: #{inspect(resp)}")
  end

  def handle_response(resp, _region), do: handle_bad_call("#{inspect(resp)}")

  #
  # INTERNAL API
  #

  def fetch_all_regions(), do: @all_regions

  def generalize_region(region) when region in @america_regions, do: {:ok, "AMERICAS"}
  def generalize_region(region) when region in @asia_regions, do: {:ok, "ASIA"}
  def generalize_region(region) when region in @euro_regions, do: {:ok, "EUROPE"}
  def generalize_region(region), do: {:error, "unknown region #{inspect(region)}"}

  #
  # HELPER FXNS
  #

  defp handle_bad_call(msg) do
    Logger.error(msg)
    {:error, msg}
  end

  defp api_key(), do: Application.fetch_env!(:lolr, :api_key)
end
