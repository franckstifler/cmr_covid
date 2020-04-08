defmodule CovidCmrWeb.PageView do
  use CovidCmrWeb, :view

  alias CovidCmr.{Repo, Don}

  def render_day_chart(donations) do
    donations
    |> Enum.group_by(fn don ->
      NaiveDateTime.to_date(don.inserted_at)
    end)
    |> Enum.reduce([], fn {key, value}, acc ->
      max_don = Enum.max_by(value, & &1.amount)
      min_don = Enum.min_by(value, & &1.amount)
      [[key, max_don.amount - min_don.amount] | acc]
    end)
    |> Enum.reverse()
    |> Jason.encode!()
  end

  def render_hour_chart(donations) do
    donations
    |> Enum.group_by(fn don ->
      %NaiveDateTime{minute: minutes, second: seconds} = don.inserted_at

      withouth_seconds_minutes =
        NaiveDateTime.add(don.inserted_at, -(minutes * 60 + seconds), :second)

      withouth_seconds_minutes
    end)
    |> Enum.reduce([], fn {key, value}, acc ->
      max_don = Enum.max_by(value, & &1.amount)
      min_don = Enum.min_by(value, & &1.amount)
      [[key, max_don.amount - min_don.amount] | acc]
    end)
    |> Enum.reverse()
    |> Jason.encode!()
  end
end
