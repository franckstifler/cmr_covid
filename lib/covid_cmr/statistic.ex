defmodule CovidCmr.Statistic do
  use GenServer
  require Logger

  @web_service Application.get_env(:covid_cmr, :web_service)
  @countries_time 10 * 24 * 60 * 60 * 1000
  @stats_time 10 * 60 * 1000
  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(_opts) do
    covid_stats = @web_service.get_covid_statistics()

    countries_infos = @web_service.get_countries_infos()

    schedule_fetch(:countries, @countries_time)
    schedule_fetch(:stats, @stats_time)

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

    schedule_fetch(:stats, @stats_time)
    {:noreply, Map.merge(state, result)}
  end

  def handle_info(:countries_info, state) do
    result = @web_service.get_countries_infos()

    schedule_fetch(:stats, @countries_time)
    {:noreply, Map.put(state, :countries, result)}
  end

  defp schedule_fetch(:countries, countries_time) do
    Process.send_after(self(), :countries_info, countries_time)
  end

  defp schedule_fetch(:stats, stats_time) do
    Process.send_after(self(), :fetch_covid_stats, stats_time)
  end

  def reschedule_fetch(item, time) when is_atom(item) do
    schedule_fetch(item, time)
  end
end
