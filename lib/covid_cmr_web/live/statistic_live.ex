defmodule CovidCmrWeb.StatisticLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    <p class="text-center">Last updated on <%= @updated %></p>
    <table>
      <tr>
        <th>Country</th>
        <th>Total Cases</th>
        <th>Total Active</th>
        <th>Total Recovered</th>
        <th>Total Deaths</th>
        <th>Today Cases</th>
        <th>Today Deaths</th>
      </tr>
      <tr>
        <td>WORLD</td>
        <td><%= format_number Map.get(@global, "cases", 0) %></td>
        <td><%= format_number Map.get(@global, "active", 0) %></td>
        <td><%= format_number Map.get(@global, "recovered", 0) %></td>
        <td><%= format_number Map.get(@global, "deaths", 0) %></td>
        <td><%= format_number Map.get(@global, "todayCases", 0) %></td>
        <td><%= format_number Map.get(@global, "todayDeaths", 0) %></td>
      </tr>
      <tr>
        <td>CAMEROON</td>
        <td><%= format_number Map.get(@local, "cases", 0) %></td>
        <td><%= format_number Map.get(@local, "active", 0) %></td>
        <td><%= format_number Map.get(@local, "recovered", 0) %></td>
        <td><%= format_number Map.get(@local, "deaths", 0) %></td>
        <td><%= format_number Map.get(@local, "todayCases", 0) %></td>
        <td><%= format_number Map.get(@local, "todayDeaths", 0) %></td>
      </tr>
    </table>
    <a href="https://github.com/novelcovid/api" _target="blank">Source of the data</a>
    """
  end

  def mount(_params, _, socket) do
    if connected?(socket) do
      :timer.send_interval(60 * 60 * 1_000, self(), :update)
    end

    %{global: global, local: local} = Statistic.get_statistics()

    updated = DateTime.from_unix!(Map.get(global, "updated", 0), :millisecond)

    {:ok,
     socket
     |> assign(:global, global)
     |> assign(:local, local)
     |> assign(:updated, DateTime.to_string(updated))}
  end

  def handle_info(:update, socket) do
    %{global: global, local: local} = Statistic.get_statistics()

    updated = DateTime.from_unix!(Map.get(global, "updated", 0), :millisecond)

    {:noreply,
     socket
     |> assign(:global, global)
     |> assign(:local, local)
     |> assign(:updated, DateTime.to_string(updated))}
  end

  def format_number(number) do
    Money.to_string(Money.new(number, :XAF), symbol: false)
  end
end
