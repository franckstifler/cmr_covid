defmodule CovidCmrWeb.PageView do
  use CovidCmrWeb, :view

  alias CovidCmr.Don

  @baseBalance 100_000
  @targets Enum.map(5..10, &(&1 * @baseBalance))

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
    |> Enum.sort(&(NaiveDateTime.compare(Enum.at(&1, 0), Enum.at(&2, 0)) == :lt))
    |> Enum.reverse()
    |> Enum.take(80)
    |> Jason.encode!()
  end

  def compute_regression(donations) do
    # take like 50% of data to estimate (since contributions are slowing with time) follow
    # current contribution behaviour

    donations = Enum.take(donations, div(Enum.count(donations), 12))

    time =
      Enum.map(
        donations,
        fn don ->
          NaiveDateTime.diff(don.inserted_at, ~N[1970-01-01 00:00:00])
        end
      )

    amounts_list = Enum.map(donations, & &1.amount)

    last_fund_raised = Enum.at(amounts_list, 1, 0)

    now = DateTime.truncate(DateTime.utc_now(), :second)

    case Numerix.LinearRegression.fit(amounts_list, time) do
      nil ->
        Enum.map(@targets, &{&1, "No Data Yet.", false})

      {intercept, slope} ->
        Enum.map(
          @targets,
          fn target ->
            {:ok, date} = DateTime.from_unix(round(target * slope + intercept))

            {target, date, Date.compare(now, date) in [:eq, :gt] and last_fund_raised >= target}
          end
        )
    end
  end
end
