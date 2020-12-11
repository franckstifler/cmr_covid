defmodule CovidCmr.DonationTest do
  use CovidCmr.DataCase
  alias CovidCmr.{Donation, Don}

  @target 1_000_000
  test "Should return {current_contribution, target}" do
    assert {0, @target} = Donation.get_new_data()
  end

  test "Should schedule fetch_contributions and persist_data" do
    Donation.schedule_fetch(100)
    Donation.schedule_save(100)

    assert_receive :fetch_contributions, 200
    assert_receive :persist_data, 200
  end

  test "Should return updated contributions" do
    assert {:noreply, {2_000_000, @target}} = Donation.handle_info(:fetch_contributions, {})
  end

  test "should persist contribution in db" do
    assert {:noreply, {500, 1000}} = Donation.handle_info(:persist_data, {500, 1000})
    [don] = Don.list_don()
    assert don.amount == 500
  end
end
