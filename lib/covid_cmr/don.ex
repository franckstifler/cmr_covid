defmodule CovidCmr.Don do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

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

  def group_by_hour do
    from(d in CovidCmr.Don, order_by: [:id])
  end

  @spec get_last_record :: Ecto.Query.t()
  def get_last_record do
    from(d in CovidCmr.Don, order_by: [desc: d.inserted_at], limit: 1)
  end
end
