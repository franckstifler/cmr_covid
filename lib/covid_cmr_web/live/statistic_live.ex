defmodule CovidCmrWeb.StatisticLive do
  use Phoenix.LiveView
  use Phoenix.HTML

  alias CovidCmr.Statistic

  @selected_countries [
    "Cameroon",
    "Nigeria",
    "Côte d'Ivoire",
    "Ghana",
    "USA",
    "Germany",
    "Italy",
    "France",
    "Spain"
  ]

  def render(assigns) do
    ~L"""
    <section class="card">
    <div>
      <h4 style="text-align: center; margin: 10px 0">Statistiques globales</h4>
      <div class="global-stats">
        <div>
          <p>Total Cases</p>
          <p><%= format_number Map.get(@global, "cases", 0) %></p>
        </div>
        <div>
          <p>Total Active</p>
          <p><%= format_number Map.get(@global, "active", 0) %></p>
        </div>
        <div>
          <p>Total Recovered</p>
          <p><%= format_number Map.get(@global, "recovered", 0) %></p>
        </div>
        <div>
          <p>Total Deaths</p>
          <p><%= format_number Map.get(@global, "deaths", 0) %></p>
        </div>
        <div>
          <p>Today Cases</p>
          <p><%= format_number Map.get(@global, "todayCases", 0) %></p>
        </div>
        <div>
          <p>Today Deaths</p>
          <p><%= format_number Map.get(@global, "todayDeaths", 0) %></p>
        </div>
      </div>
    </div>
    <%= f = form_for :form, "#", [phx_change: :search]  %>
      <%= text_input f, :search, placeholder: "Search country" %>
    </form>
    <div class="country-container">
    <%= for stats <- @local do %>
    <div class="country-item">
    <h4 class="text-center"><img height=15px width=auto src=<%= stats["countryInfo"]["flag"]%>> <%= stats["country"] %> </img></h4>
    <p>Total Cases: <%= format_number Map.get(stats, "cases", 0) %></p>
    <p>Total Active: <%= format_number Map.get(stats, "active", 0) %></p>
    <p>Total Recovered: <%= format_number Map.get(stats, "recovered", 0) %></p>
    <p>Total Deaths: <%= format_number Map.get(stats, "deaths", 0) %></p>
    <p>Today Cases: <%= format_number Map.get(stats, "todayCases", 0) %></p>
    <p>Today Deaths: <%= format_number Map.get(stats, "todayDeaths", 0) %></p>
    <p>Mortality: <%= Map.get(stats, "mortality", 0)  %>%</p>
    <% details = get_country_detail(@countries, stats) %>
    <p>Population: <%= format_number details.population %></p>
    <p>Area: <%= details.area %> KM<sup>2</sup></p>
    </div>
    <% end %>
    </div>
    <a href="https://github.com/novelcovid/api" _target="blank">Source of the data</a>
    <p>D'autres pays a ajouter a la liste? Laissez moi un mail </p>
    </section>
    """
  end

  def mount(_params, _, socket) do
    if connected?(socket) do
      :timer.send_interval(10 * 60 * 1_000, self(), :update)
    end

    %{global: global, local: local, countries: countries} = Statistic.get_statistics()

    global = Map.put(global, "mortality", compute_mortality_percentage(global))

    selected = process_stats(local)

    {:ok,
     socket
     |> assign(:global, global)
     |> assign(:countries, countries)
     |> assign(:all_countries_data, selected)
     |> assign(:local, selected)}
  end

  def handle_event("search", %{"form" => %{"search" => search}}, socket) do
    matching_countries =
      Enum.filter(socket.assigns.all_countries_data, fn country ->
        String.contains?(String.downcase(country["country"]), String.downcase(search))
      end)

    {:noreply, assign(socket, local: matching_countries)}
  end

  def handle_info(:update, socket) do
    %{global: global, local: local, countries: countries} = Statistic.get_statistics()

    global = Map.put(global, "mortality", compute_mortality_percentage(global))
    selected = process_stats(local)

    {:noreply,
     socket
     |> assign(:global, global)
     |> assign(:countries, countries)
     |> assign(:all_countries_data, selected)
     |> assign(:local, selected)}
  end

  defp process_stats(local) do
    all =
      local
      |> Enum.map(fn stats ->
        mortality = compute_mortality_percentage(stats)

        Map.put(stats, "mortality", mortality)
      end)

    filtered =
      all
      |> Enum.filter(fn stats ->
        stats["country"] in @selected_countries
      end)

    filtered ++ all
  end

  defp compute_mortality_percentage(stats) do
    cases = Map.get(stats, "cases", 0)
    deaths = Map.get(stats, "deaths", 1)

    (String.to_integer("#{deaths}") / String.to_integer("#{cases}"))
    |> Kernel.*(100)
    |> Float.ceil(2)
  end

  def format_number(number) do
    Money.to_string(Money.new(number, :XAF), symbol: false)
  end

  def format_date(stat) do
    DateTime.from_unix!(Map.get(stat, "updated", 0), :millisecond)
    |> Date.to_string()
  end

  defp get_country_detail(countries, country) do
    found =
      Enum.find(countries, fn c ->
        c["alpha3Code"] == country["countryInfo"]["iso3"]
      end)

    if found == nil do
      %{population: 0, area: 0}
    else
      %{population: found["population"], area: found["area"]}
    end
  end
end
