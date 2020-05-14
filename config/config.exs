# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :covid_cmr, CovidCmr.Repo,
  url: "postgres://nojlkafckhgwtx:c9388c031b6e162c8b1fb740100a7895cb54decb211b56a42b9deac8a605170d@ec2-52-207-93-32.compute-1.amazonaws.com:5432/d7itqlhecr9nc1",
  ssl: true,
  pool_size: 2,
  queue_target: 100,
  queue_interval: 10000

# Configures the endpoint
config :covid_cmr, CovidCmrWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "rFW+3LmUV0fjC+sHGKXRVVbqSgjvDN3Z39Et61v4WW7+d4ykSis+ZHn37slN29oB",
  render_errors: [view: CovidCmrWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: CovidCmr.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :covid_cmr, CovidCmrWeb.Endpoint,
  live_view: [
    signing_salt: "wPf5VbrzrHJFtm8lrK8l8drZvDG7MYqJ"
  ]

config :money,
  default_currency: :XAF

config :covid_cmr,
  ecto_repos: [CovidCmr.Repo]

config :chartkick, json_serializer: Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
