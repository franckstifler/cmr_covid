defmodule CovidCmrWeb.StatisticLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    <section class="card">
    <h3>2- Données sur l'évolution du coronavirus au Cameroun et dans certains pays du monde</h3>
    <small class="text-center">D'autres pays a ajouter a la liste? Laissez moi un mail </small>
    <table>
      <tr>
        <th>Country</th>
        <th>Total Cases</th>
        <th>Total Active</th>
        <th>Total Recovered</th>
        <th>Total Deaths</th>
        <th>Today Cases</th>
        <th>Today Deaths</th>
        <th>Updated On</th>
      </tr>
      <tr>
        <td>WORLD</td>
        <td><%= format_number Map.get(@global, "cases", 0) %></td>
        <td><%= format_number Map.get(@global, "active", 0) %></td>
        <td><%= format_number Map.get(@global, "recovered", 0) %></td>
        <td><%= format_number Map.get(@global, "deaths", 0) %></td>
        <td><%= format_number Map.get(@global, "todayCases", 0) %></td>
        <td><%= format_number Map.get(@global, "todayDeaths", 0) %></td>
        <td><%= format_date @global %></td>
      </tr>
      <%= for stats <- @local do %>
        <tr>
          <td><%= stats["country"] %> <img height=10px width=auto src=<%= stats["countryInfo"]["flag"]%>></img></td>
          <td><%= format_number Map.get(stats, "cases", 0) %></td>
          <td><%= format_number Map.get(stats, "active", 0) %></td>
          <td><%= format_number Map.get(stats, "recovered", 0) %></td>
          <td><%= format_number Map.get(stats, "deaths", 0) %></td>
          <td><%= format_number Map.get(stats, "todayCases", 0) %></td>
          <td><%= format_number Map.get(stats, "todayDeaths", 0) %></td>
          <td><%= format_date stats %></td>
          </tr>
      <% end %>
    </table>
    <a href="https://github.com/novelcovid/api" _target="blank">Source of the data</a>
    </section>
    """
  end

  def mount(_params, _, socket) do
    if connected?(socket) do
      :timer.send_interval(10 * 60 * 1_000, self(), :update)
    end

    %{global: global, local: local} = Statistic.get_statistics()

    selected_countries = ["Cameroon", "Germany", "USA", "France"]

    selected =
      Enum.filter(local, fn stats ->
        stats["country"] in selected_countries
      end)

    {:ok,
     socket
     |> assign(:global, global)
     |> assign(:local, selected)}
  end

  def handle_info(:update, socket) do
    %{global: global, local: local} = Statistic.get_statistics()

    selected_countries = ["Cameroon", "Germany", "USA", "France"]

    selected =
      Enum.filter(local, fn stats ->
        stats["country"] in selected_countries
      end)

    {:noreply,
     socket
     |> assign(:global, global)
     |> assign(:local, selected)}
  end

  def format_number(number) do
    Money.to_string(Money.new(number, :XAF), symbol: false)
  end

  def format_date(stat) do
    DateTime.from_unix!(Map.get(stat, "updated", 0), :millisecond)
    |> Date.to_string()
  end
end
