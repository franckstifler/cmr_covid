defmodule CovidCmrWeb.DashboardLive do
  use Phoenix.LiveView
  alias CovidCmr.Donation

  @counter 60
  def render(assigns) do
    ~L"""
    <section class="card">
    <h3 class="text-center">OBJECTIF ATTEINT / OBJECTIVE ATTAINED <small>(1 EUR ~= 655.957 XAF ~= 1.08 USD)</small></h4>
    <p class="text-center" style="color: blue; font-weight: bold"> Mise a jour en: <%= @counter %></p>
    <div class="country-container">
      <%= for contribution <- @contributions do %>
        <div class="country-item" style="width: 300px">
            <h4 class="text-center"><%= contribution.currency %> </img></h4>
            <div>
              <p>Target: <%= Money.parse!(contribution.target, contribution.currency) %></p>
              <p>Current: <%= Money.parse!(contribution.current, contribution.currency) %></p>
              <p>Remaining: <%= Money.parse!(contribution.target - contribution.current, contribution.currency) %></p>
              <p>Percentage: <%= @percentage  %>%</p>
            </div>
        </div>
      <% end %>
    </div>
    <br>
    <h6 class="text-center"><a href="https://cameroonsurvival.org/fr/dons/" target="_blank">Faire un don SCSI </a></h6>
    </section>
    """
  end

  def mount(_params, _, socket) do
    if connected?(socket) do
      :timer.send_interval(1000, self(), :counter)
      :timer.send_interval(60_000, self(), :update)
    end

    {current, target} = Donation.get_new_data()

    contributions = convert_to_currencies(current, target)
    percentage = (current * 100 / target) |> Float.floor(2)

    {:ok,
     socket
     |> assign(:contributions, contributions)
     |> assign(:percentage, percentage)
     |> assign(:counter, @counter)}
  end

  def handle_info(:update, socket) do
    {current, target} = Donation.get_new_data()

    contributions = convert_to_currencies(current, target)

    percentage = (current * 100 / target) |> Float.floor(2)

    {:noreply,
     socket
     |> assign(:contributions, contributions)
     |> assign(:percentage, percentage)}
  end

  def handle_info(:counter, socket) do
    counter = socket.assigns.counter

    socket =
      cond do
        counter > 0 ->
          assign(socket, :counter, counter - 1)

        true ->
          assign(socket, :counter, @counter)
      end

    {:noreply, socket}
  end

  defp convert_to_currencies(current, target) do
    [EUR: 1, XAF: 655.957, USD: 1.08]
    |> Enum.map(fn {currency, factor} ->
      %{currency: currency, current: current * factor, target: target * factor}
    end)
    |> IO.inspect()
  end
end
