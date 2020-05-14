defmodule Statistic do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(_opts) do
    send(self(), :fetch)
    send(self(), :countries_info)
    # fetch stats after 5 minutes.
    schedule_fetch(:stats)
    # Fetch countries info after 10 days.
    schedule_fetch(:countries)
    {:ok, %{local: %{}, global: %{}}}
  end

  def get_statistics() do
    GenServer.call(__MODULE__, :statistic)
  end

  def handle_call(:statistic, _from, state) do
    {:reply, state, state}
  end

  def handle_info(:fetch, state) do
    result = get_stats()

    schedule_fetch(:stats)
    {:noreply, Map.merge(state, result)}
  end

  def handle_info(:countries_info, state) do
    result = get_countries_infos()
    {:noreply, Map.put(state, :countries, result)}
  end

  defp get_countries_infos do
    countries_url = "https://restcountries.eu/rest/v2/all"

    case HTTPoison.get(countries_url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        Jason.decode!(body)

      _ ->
        []
    end
  end

  defp get_stats do
    global_url = "https://corona.lmao.ninja/v2/all?yesterday=true"
    all_url = "https://corona.lmao.ninja/v2/countries?yesterday=true"

    stats = %{}

    stats =
      case HTTPoison.get(global_url) do
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          stats
          |> Map.put(:global, Jason.decode!(body))

        _ ->
          Map.put(stats, :global, %{})
      end

    stats =
      case HTTPoison.get(all_url) do
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          stats
          |> Map.put(:local, Jason.decode!(body))

        _ ->
          Map.put(stats, :local, [])
      end

    stats
  end

  defp schedule_fetch(:countries) do
    Process.send_after(self(), :countries_info, 10 * 24 * 60 * 60 * 1000)
  end

  defp schedule_fetch(:stats) do
    Process.send_after(self(), :fetch, 5 * 60 * 1000)
  end
end
