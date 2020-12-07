defmodule CovidCmr.Statistic do
  use GenServer
  require Logger

  @web_service Application.get_env(:covid_cmr, :web_service)

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(_opts) do
    covid_stats = @web_service.get_covid_statistics()

    countries_infos = @web_service.get_countries_infos()

    schedule_fetch(:countries)
    schedule_fetch(:stats)

    {:ok, Map.put(covid_stats, :countries, countries_infos)}
  end

  def get_statistics() do
    GenServer.call(__MODULE__, :statistic)
  end

  def handle_call(:statistic, _from, state) do
    {:reply, state, state}
  end

  def handle_info(:fetch_covid_stats, state) do
    result = @web_service.get_covid_statistics()

    schedule_fetch(:stats)
    {:noreply, Map.merge(state, result)}
  end

  def handle_info(:countries_info, state) do
    result = @web_service.get_countries_infos()
    {:noreply, Map.put(state, :countries, result)}
  end

  defp schedule_fetch(:countries) do
    Process.send_after(self(), :countries_info, 10 * 24 * 60 * 60 * 1000)
  end

  defp schedule_fetch(:stats) do
    Process.send_after(self(), :fetch_covid_stats, 10 * 60 * 1000)
  end
end
