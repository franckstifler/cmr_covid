defmodule CovidCmr.WebService.HTTPClient do
  require Logger

  @countries_url "https://restcountries.eu/rest/v2/all?fields=population;area;alpha3Code;flag;capital"
  @global_url "https://disease.sh/v3/covid-19/all?yesterday=true"
  @all_url "https://disease.sh/v3/covid-19/countries?yesterday=true"
  @survie_url "https://cameroonsurvival.org/fr/dons/"
  @behaviour CovidCmr.WebService

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

        {:error, error} ->
          Logger.log(:warning, error)
          Map.put(stats, :global, %{})
      end

    stats =
      case HTTPoison.get(@all_url) do
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          stats
          |> Map.put(:local, Jason.decode!(body))

        {:error, error} ->
          Logger.log(:warning, error)
          Map.put(stats, :local, [])
      end

    stats
  end

  def get_current_contributions(url \\ @survie_url) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, document} =
          body
          |> Floki.parse_document()

        [current, _target] =
          document
          |> Floki.attribute("span", "data-amounts")
          |> Enum.map(fn x ->
            Jason.decode!(x)
          end)

        current = String.replace(current["EUR"], "€", "")

        case Float.parse(current) do
          {parsed, _} ->
            {:ok, trunc(parsed * 1_000_000)}

          _ ->
            {:error, :parsing_failed}
        end

      _ ->
        {:error, :failed_fetch}
    end
  end
end
