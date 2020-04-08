defmodule CovidCmrWeb.DashboardLive do
  use Phoenix.LiveView

  @counter 60
  def render(assigns) do
    ~L"""
    <p class="text-center">
    <small class="text-center">1 EUR ~= 655.957 XAF ~= 1.08 USD</small>
    <br><small class="text-center" style="color: blue; font-weight: bold"> Mise a jour en: <%= @counter %></small>
    </p>
    <table>
    <tr>
    <th>Currency</th>
    <th>Target</th>
    <th>Current</th>
        <th>Remaining</th>
        </tr>
        <tr>
        <td>EUR</td>
        <td style="color: blue;"><%= Money.parse!(@target, :EUR) %></td>
        <td style="color: green;"><%= Money.parse!(@current, :EUR) %></td>
        <td style="color: red;"><%= Money.parse!(@balance, :EUR) %></td>
        </tr>
      <tr>
      <td>XAF</td>
      <td style="color: blue;"><%= Money.parse!(@target * 655.957) %></td>
        <td style="color: green;"><%= Money.parse!(@current * 655.957) %></td>
        <td style="color: red;"><%= Money.parse!(@balance * 655.957) %></td>
        </tr>
        <tr>
        <td>USD</td>
        <td style="color: blue;"><%= Money.parse!(@target * 1.08, :USD) %></td>
        <td style="color: green;"><%= Money.parse!(@current * 1.08, :USD) %></td>
        <td style="color: red;"><%= Money.parse!(@balance * 1.08, :USD) %></td>
      </tr>
    </table>
    <h6 class="text-center"><a href="https://cameroonsurvival.org/fr/dons/" target="_blank">Faire un don a Survival Cameroon </a></h6>
    """
  end

  def mount(_params, _, socket) do
    if connected?(socket) do
      :timer.send_interval(1000, self(), :counter)
      :timer.send_interval(60_000, self(), :update)
    end

    {current, target} = Donation.get_new_data()

    {:ok,
     socket
     |> assign(:target, target)
     |> assign(:current, current)
     |> assign(:balance, target - current)
     |> assign(:counter, @counter)}
  end

  def handle_info(:update, socket) do
    {current, target} = Donation.get_new_data()

    {:noreply,
     socket
     |> assign(:target, target)
     |> assign(:current, current)
     |> assign(:balance, target - current)}
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
end
