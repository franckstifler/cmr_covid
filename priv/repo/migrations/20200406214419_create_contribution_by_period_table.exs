defmodule CovidCmr.Repo.Migrations.CreateContributionByPeriodTable do
  use Ecto.Migration

  def change do
    create table(:donations) do
      add(:amount, :integer)
      timestamps(updated_at: false)
    end

    create unique_index(:donations, :amount)
  end
end
