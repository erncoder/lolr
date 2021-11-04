# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :lolr,
  api_key: System.get_env("RIOT_API_KEY", "none")

# Configures the endpoint
config :lolr, LolrWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: LolrWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: Lolr.PubSub,
  live_view: [signing_salt: "n58VdI/x"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
