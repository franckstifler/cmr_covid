defmodule CovidCmr.WebService do
  @doc """
  Gets all the covid statistics of the previous day and today.

  Global map will contain the glogal statistics of the pandemic all over the world, while
  the local will be the ones of every country.
  """
  @callback get_covid_statistics() :: %{global: map(), local: list()}

  @doc """
  Returns information about countries. Currently filtered to return some given fields
  such as population, area...
  """
  @callback get_countries_infos() :: list()
end
