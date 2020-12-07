use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :covid_cmr, CovidCmrWeb.Endpoint,
  http: [port: 4002],
  server: false

config :covid_cmr, CovidCmr.Repo,
  username: "postgres",
  password: "postgres",
  database: "covid_cmr_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :covid_cmr, web_service: CovidCmr.WebService.InMemory

# Print only warnings and errors during test
config :logger, level: :warn
