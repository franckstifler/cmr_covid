defmodule CovidCmr.WebService.InMemory do
  @behaviour CovidCmr.WebService

  def get_countries_infos() do
    [
      %{
        "alpha3Code" => "AFG",
        "area" => 652_230.0,
        "capital" => "Kabul",
        "flag" => "https://restcountries.eu/data/afg.svg",
        "population" => 27_657_145
      },
      %{
        "alpha3Code" => "ALA",
        "area" => 1580.0,
        "capital" => "Mariehamn",
        "flag" => "https://restcountries.eu/data/ala.svg",
        "population" => 28875
      }
    ]
  end

  def get_covid_statistics() do
    %{global: %{}, local: []}
  end
end
