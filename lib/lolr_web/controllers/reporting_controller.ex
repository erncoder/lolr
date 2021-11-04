defmodule LolrWeb.ReportingController do
  @moduledoc """
  Controller for api calls on the `reporting` context
  """

  use LolrWeb, :controller

  alias Lolr.Reporting

  def start(conn, %{"region" => region, "summoner" => summoner}) do
    {:ok, names} = Reporting.start(region, summoner)

    conn |> json(names)
  end
end
