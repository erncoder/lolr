defmodule LolrWeb.ReportingController do
  use LolrWeb, :controller

  alias Lolr.Reporting

  def start(conn, %{"region" => region, "summoner" => summoner}) do
    {:ok, names} = Reporting.start(region, summoner)

    conn |> json(names)
  end
end
