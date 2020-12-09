defmodule CovidCmr.DonTest do
  use CovidCmr.DataCase

  alias CovidCmr.Don

  @valid_attrs %{amount: 300}
  @invalid_attrs %{amount: nil}

  def fixture(attrs \\ @valid_attrs) do
    {:ok, don} = Don.create_don(attrs)

    don
  end

  test "create_don/1 Should create a don with valid attrs" do
    assert {:ok, %Don{} = don} = Don.create_don(@valid_attrs)

    assert don.amount == 300
  end

  test "create_don/1 with invalid attrs should not be created" do
    assert {:error, changeset} = Don.create_don(@invalid_attrs)

    assert %{
             amount: ["can't be blank"]
           } == errors_on(changeset)
  end

  test "create_don/1 with same amount should fail" do
    don = fixture()

    assert Don.list_don() == [don]

    assert {:error, changeset} = Don.create_don(@valid_attrs)

    assert %{amount: ["has already been taken"]} == errors_on(changeset)

    assert Don.list_don() == [don]
  end

  test "get_last_record/0 should return nil if no record inserted" do
    assert is_nil(Don.get_last_record())
  end

  test "get_last_record/0 should return the most recent inserted record" do
    recent_record_attrs = %{amount: 500}
    fixture()
    # create delay between both inserts
    Process.sleep(1000)
    assert {:ok, recent_record} = Don.create_don(recent_record_attrs)
    assert recent_record == Don.get_last_record()
  end

  test "list_don/0 return dons from database in ordered descendant" do
    don = fixture()
    Process.sleep(1000)
    don1 = fixture(%{amount: 230})

    assert Don.list_don() == [don1, don]
  end
end
