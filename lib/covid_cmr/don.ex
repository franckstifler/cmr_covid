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
    from(
      d in CovidCmr.Don,
      group_by: fragment("extract(hour from ?) ", d.inserted_at),
      select: {
        fragment("extract(hour from ?)", d.inserted_at),
        fragment("max(?) - min(?)", d.amount, d.amount)
      }
    )
  end

end
