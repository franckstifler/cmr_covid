defmodule CovidCmr.Repo do
  use Ecto.Repo,
    otp_app: :covid_cmr,
    adapter: Ecto.Adapters.Postgres
end
