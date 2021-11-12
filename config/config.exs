# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :triad_api,
  ecto_repos: [TriadApi.Repo]

# Configures the endpoint
config :triad_api, TriadApiWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "01IcMI3FDbHiK3RRBiFnWPUrcONAxp0jG7Qnxsz91NY6nGgVJcMbYfUTdGNSIy56",
  render_errors: [view: TriadApiWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: TriadApi.PubSub,
  live_view: [signing_salt: "NRByolnW"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Guardian config
config :triad_api, TriadApi.Guardian,
  issuer: "triad_api",
  secret_key: "1kS3SpNiBJPOAy1Zjaa6+ymFXbIaOwYxpvr7LGwNPxDz3BANJuiPny6k52dvuxTJ"

config :triad_api, TriadApi.Repo,
  migration_primary_key: [name: :id, type: :uuid, autogenerate: false, read_after_writes: true, default: {:fragment, "uuid_generate_v4()"}]
# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
