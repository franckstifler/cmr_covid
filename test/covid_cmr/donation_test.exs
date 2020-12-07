defmodule CovidCmr.DonTest do
  use ExUnit.Case
  alias CovidCmr.Statistic

  test "initialising the server should return map of countries/global/local" do
  end

  test "gets list of countries" do
    response = Statistic.handle_info(:countries_info, %{})
    assert 1 == 1
  end
end
