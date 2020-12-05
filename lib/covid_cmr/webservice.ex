defmodule CovidCmr.WebService do
  @countries_url "https://restcountries.eu/rest/v2/all?fields=population;area;alpha3Code;flag;capital"
  @global_url "https://disease.sh/v3/covid-19/all?yesterday=true"
  @all_url "https://disease.sh/v3/covid-19/countries?yesterday=true"
  require Logger
  @behaviour CovidCmr.WebServiceBehaviour

  def get_countries_infos do
    case HTTPoison.get(@countries_url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        Jason.decode!(body)

      _ ->
        []
    end
  end

  def get_covid_statistics do
    stats = %{}

    stats =
      case HTTPoison.get(@global_url) do
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          stats
          |> Map.put(:global, Jason.decode!(body))

        error ->
          Logger.log(:warning, error)
          Map.put(stats, :global, %{})
      end

    stats =
      case HTTPoison.get(@all_url) do
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          stats
          |> Map.put(:local, Jason.decode!(body))

        error ->
          Logger.log(:warning, error)
          Map.put(stats, :local, [])
      end

    stats
  end
end
