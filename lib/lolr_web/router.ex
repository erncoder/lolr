defmodule LolrWeb.Router do
  use LolrWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", LolrWeb do
    pipe_through :api

    post "/start/:region/:summoner", ReportingController, :start
  end
end
