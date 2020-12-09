defmodule CovidCmr.Don do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias CovidCmr.Repo
  alias CovidCmr.Don

  schema("donations") do
    field(:amount, :integer)

    timestamps(updated_at: false)
  end

  def changeset(don, attrs) do
    don
    |> cast(attrs, [:amount])
    |> validate_required([:amount])
    |> unique_constraint(:amount)
  end

  def list_don do
    from(d in CovidCmr.Don, order_by: [desc: d.id])
    |> Repo.all()
  end

  def get_last_record do
    from(d in CovidCmr.Don, order_by: [desc: d.inserted_at], limit: 1)
    |> Repo.one()
  end

  def create_don(attrs \\ %{}) do
    %Don{}
    |> Don.changeset(attrs)
    |> Repo.insert()
  end
end
