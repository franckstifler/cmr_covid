defmodule CovidCmr.Statistic do
  use GenServer
  require Logger
  alias CovidCmr.WebService

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(_opts) do
    covid_stats = WebService.get_covid_statistics()
    countries_infos = WebService.get_countries_infos()

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
    result = WebService.get_covid_statistics()

    schedule_fetch(:stats)
    {:noreply, Map.merge(state, result)}
  end

  def handle_info(:countries_info, state) do
    IO.inspect("Wer're here")
    result = WebService.get_countries_infos()
    {:noreply, Map.put(state, :countries, result)}
  end

  defp schedule_fetch(:countries) do
    Process.send_after(self(), :countries_info, 10 * 24 * 60 * 60 * 1000)
  end

  defp schedule_fetch(:stats) do
    Process.send_after(self(), :fetch, 10 * 60 * 1000)
  end
end
