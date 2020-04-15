defmodule Statistic do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(_opts) do
    {:ok, %{local: %{}, global: %{}}}
  end

  def get_statistics() do
    GenServer.call(__MODULE__, :statistic)
  end

  def handle_call(:statistic, _from, _state) do
    result = get_stats()
    {:reply, result, result}
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
end
