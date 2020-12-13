# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

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

if Mix.env() != :prod do
  config :git_hooks,
    auto_install: true,
    verbose: true,
    hooks: [
      pre_commit: [
        tasks: [
          {:cmd, "mix format"}
        ]
      ],
      pre_push: [
        verbose: false,
        tasks: [
          {:cmd, "mix dialyzer"},
          {:cmd, "mix test"},
          {:cmd, "echo 'success!'"}
        ]
      ]
    ]
end

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
