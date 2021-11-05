defmodule Lolr.Reporting.WorkerTest do
  @moduledoc """
  Note: this test relies on the MockMe package a co-worker's project that doesn't allow for dynamic responses, yet
  """

  use ExUnit.Case

  alias Lolr.Models.Summoner
  alias Lolr.Reporting.Worker, as: TestMe
  alias Lolr.Reporting.Worker.State

  @moduletag :reporting

  describe "handle_info/2" do
    test "correctly decrements `mins_left` and updates `last_check` if given valid args" do
      dt = DateTime.utc_now() |> DateTime.to_unix()

      Process.sleep(500)

      assert {:noreply,
              %State{
                mins_left: 98,
                last_check: nt
              }} =
               TestMe.handle_info(:tick, %State{
                 name: "Bob",
                 region: "NA1",
                 summoners: [],
                 mins_left: 99,
                 last_check: dt
               })

      assert nt > dt
    end
  end
end
