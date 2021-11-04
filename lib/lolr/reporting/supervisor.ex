defmodule Lolr.Reporting.Supervisor do
  @moduledoc """
  Dynamically supervises Reporting.Worker GenServers
  """

  use DynamicSupervisor
  alias __MODULE__, as: Me

  def start_link(opts \\ []), do: DynamicSupervisor.start_link(Me, opts, name: Me)
  def init(_opts \\ []), do: DynamicSupervisor.init(strategy: :one_for_one)
end
