defmodule CovidCmr.StatisticTest do
  use ExUnit.Case
  alias CovidCmr.Statistic

  @countries [
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

  @stats %{
    global: %{
      "active" => 19_539_149,
      "activePerOneMillion" => 2507.44,
      "affectedCountries" => 220,
      "cases" => 68_557_411,
      "casesPerOneMillion" => 8795,
      "critical" => 106_367,
      "criticalPerOneMillion" => 13.65,
      "deaths" => 1_562_287,
      "deathsPerOneMillion" => 200.4,
      "oneCasePerPeople" => 0,
      "oneDeathPerPeople" => 0,
      "oneTestPerPeople" => 0,
      "population" => 7_792_461_683,
      "recovered" => 47_455_975,
      "recoveredPerOneMillion" => 6089.99,
      "tests" => 1_069_682_451,
      "testsPerOneMillion" => 137_271.44,
      "todayCases" => 591_886,
      "todayDeaths" => 11861,
      "todayRecovered" => 448_055,
      "updated" => 1_607_510_926_246
    },
    local: [
      %{
        "active" => 8425,
        "activePerOneMillion" => 214.34,
        "cases" => 48366,
        "casesPerOneMillion" => 1230,
        "continent" => "Asia",
        "country" => "Afghanistan",
        "countryInfo" => %{
          "_id" => 4,
          "flag" => "https://disease.sh/assets/img/flags/af.png",
          "iso2" => "AF",
          "iso3" => "AFG",
          "lat" => 33,
          "long" => 65
        },
        "critical" => 93,
        "criticalPerOneMillion" => 2.37,
        "deaths" => 1908,
        "deathsPerOneMillion" => 49,
        "oneCasePerPeople" => 813,
        "oneDeathPerPeople" => 20601,
        "oneTestPerPeople" => 243,
        "population" => 39_307_198,
        "recovered" => 38033,
        "recoveredPerOneMillion" => 967.58,
        "tests" => 161_864,
        "testsPerOneMillion" => 4118,
        "todayCases" => 230,
        "todayDeaths" => 6,
        "todayRecovered" => 49,
        "updated" => 1_607_510_926_505
      },
      %{
        "active" => 20973,
        "activePerOneMillion" => 7291.38,
        "cases" => 44436,
        "casesPerOneMillion" => 15448,
        "continent" => "Europe",
        "country" => "Albania",
        "countryInfo" => %{
          "_id" => 8,
          "flag" => "https://disease.sh/assets/img/flags/al.png",
          "iso2" => "AL",
          "iso3" => "ALB",
          "lat" => 41,
          "long" => 20
        },
        "critical" => 35,
        "criticalPerOneMillion" => 12.17,
        "deaths" => 936,
        "deathsPerOneMillion" => 325,
        "oneCasePerPeople" => 65,
        "oneDeathPerPeople" => 3073,
        "oneTestPerPeople" => 14,
        "population" => 2_876_410,
        "recovered" => 22527,
        "recoveredPerOneMillion" => 7831.64,
        "tests" => 201_572,
        "testsPerOneMillion" => 70078,
        "todayCases" => 753,
        "todayDeaths" => 14,
        "todayRecovered" => 347,
        "updated" => 1_607_510_926_506
      }
    ]
  }
  test "initialising the server should return map of countries/global/local" do
    response = Statistic.get_statistics()
    assert response.global == @stats.global
    assert response.local == @stats.local
    assert response.countries == @countries
  end

  test "Statistic.handle_info/0 gets list of countries" do
    assert {:noreply, response} = Statistic.handle_info(:countries_info, %{})

    assert %{countries: @countries} == response
  end

  test "get covid stats" do
    assert {:noreply, response} = Statistic.handle_info(:fetch_covid_stats, %{})

    assert %{global: @stats.global, local: @stats.local} == response
  end

  test "fetch of stats should be rescheduled after timeout" do
    Statistic.reschedule_fetch(:stats, 1000)

    assert_receive :fetch_covid_stats, 2000
  end
end
