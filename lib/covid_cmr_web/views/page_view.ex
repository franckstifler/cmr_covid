defmodule CovidCmrWeb.PageView do
  use CovidCmrWeb, :view

  alias CovidCmr.{Repo, Don}

  @baseBalance 100_000

  def render_day_chart(donations) do
    donations
    |> Enum.group_by(fn don ->
      NaiveDateTime.to_date(don.inserted_at)
    end)
    |> Enum.reduce(
      [],
      fn {key, value}, acc ->
        max_don = Enum.max_by(value, & &1.amount)
        min_don = Enum.min_by(value, & &1.amount)
        [[key, max_don.amount - min_don.amount] | acc]
      end
    )
    |> Enum.reverse()
    |> Jason.encode!()
  end

  def render_hour_chart(donations) do
    donations
    |> Enum.group_by(fn don ->
      %NaiveDateTime{minute: minutes, second: seconds} = don.inserted_at

      without_seconds_minutes =
        NaiveDateTime.add(don.inserted_at, -(minutes * 60 + seconds), :second)

      without_seconds_minutes
    end)
    |> Enum.reduce(
      [],
      fn {key, value}, acc ->
        max_don = Enum.max_by(value, & &1.amount)
        min_don = Enum.min_by(value, & &1.amount)
        [[key, max_don.amount - min_don.amount] | acc]
      end
    )
    |> Enum.reverse()
    |> Jason.encode!()
  end

  def compute_regression(donations) do
    time =
      Enum.map(
        donations,
        fn don ->
          NaiveDateTime.diff(don.inserted_at, ~N[1970-01-01 00:00:00])
        end
      )

    amount = Enum.map(donations, & &1.amount)

    {intercept, slope} = Numerix.LinearRegression.fit(amount, time)

    targets = Enum.map(5..10, &(&1 * @baseBalance))

    now = DateTime.truncate(DateTime.utc_now(), :second)

    expected_dates =
      Enum.map(
        targets,
        fn target ->
          {:ok, date} = DateTime.from_unix(round(target * slope + intercept))
          {target, date, Date.compare(now, date) in [:eq, :gt]}
        end
      )

    correlation = Numerix.LinearRegression.r_squared(amount, time)

    %{
      coeffs: {intercept, slope, correlation},
      targets: expected_dates
    }
  end
end
