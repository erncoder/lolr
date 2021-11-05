defmodule Lolr.Reporting.Worker do
  @moduledoc """
  This GenServer drives match checking and reporting for a particular "flight" of summoners.
  """

  use GenServer

  alias __MODULE__, as: Me

  alias Lolr.Clients.Riot
  alias Lolr.Models.Summoner
  alias Lolr.Reporting.Supervisor, as: ReportingSupervisor

  require Logger

  @minutes_to_live 60
  @one_minute 60_000

  defmodule State do
    @moduledoc false

    @required_fields [:name, :region, :summoners, :mins_left, :last_check]
    defstruct @required_fields
  end

  def start_link(opts) do
    GenServer.start_link(Me, opts)
  end

  def init(opts) do
    state = %State{
      name: Keyword.fetch!(opts, :name),
      region: Keyword.fetch!(opts, :region),
      summoners: Keyword.fetch!(opts, :summoners),
      mins_left: @minutes_to_live,
      last_check: get_unix_now()
    }

    Logger.debug("starting reporting for #{state.name}")
    Process.send_after(self(), :tick, @one_minute)
    {:ok, state}
  end

  def handle_info(
        :tick,
        %State{
          name: name,
          mins_left: mins_left,
          last_check: last_check
        } = state
      ) do
    Logger.debug("[[ #{mins_left} ]] checking flight \"#{name}\" from epoch #{last_check}")

    Process.send_after(self(), :tick, @one_minute)
    new_last_check = get_unix_now()

    new_mins_left = max(0, mins_left - 1)

    state =
      if new_mins_left == 0 do
        DynamicSupervisor.terminate_child(ReportingSupervisor, self())
      else
        check_matches(state)

        Map.merge(state, %{
          mins_left: new_mins_left,
          last_check: new_last_check
        })
      end

    {:noreply, state}
  end

  def check_matches(%State{region: region, summoners: summoners, last_check: last_check}) do
    summoners
    |> Enum.take_while(fn %Summoner{name: name, puuid: puuid} ->
      case Riot.get_match_history_by_puuid(region, puuid, 5, last_check) do
        {:ok, fetched_matches} ->
          for fetched_match <- fetched_matches do
            Logger.info("Summoner #{name} completed match #{fetched_match}")
            true
          end

        {:warn, :rate_limited} ->
          Logger.warn("Riot Client HIT THE RATE LIMIT -- skipping remaining")
          false
      end
    end)
  end

  defp get_unix_now(), do: DateTime.utc_now() |> DateTime.to_unix()
end
