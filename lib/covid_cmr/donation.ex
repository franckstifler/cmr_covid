defmodule CovidCmr.Donation do
  use GenServer
  alias CovidCmr.Don

  # Insert in db after 10 mins.
  @save_interval 10 * 60 * 1000
  # Fectch triggered by live-view every 45 sec
  @fetch_interval 45 * 1000
  # target for the survival project
  @target 1_000_000
  @web_service Application.get_env(:covid_cmr, :web_service)

  def start_link(_opts) do
    current =
      case Don.get_last_record() do
        nil ->
          0

        don ->
          don.amount
      end

    GenServer.start_link(__MODULE__, {current, @target}, name: __MODULE__)
  end

  def init(state) do
    schedule_fetch()
    schedule_save()

    {:ok, state}
  end

  def get_new_data do
    GenServer.call(__MODULE__, :get, 10_000)
  end

  def schedule_fetch(fetch_interval \\ @fetch_interval) do
    Process.send_after(self(), :fetch_contributions, fetch_interval)
  end

  def schedule_save(save_interval \\ @save_interval) do
    Process.send_after(self(), :persist_data, save_interval)
  end

  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end

  def handle_info(:fetch_contributions, state) do
    case @web_service.get_current_contributions() do
      {:ok, current} ->
        schedule_fetch()
        {:noreply, {current, @target}}

      _ ->
        schedule_fetch()
        {:noreply, state}
    end
  end

  def handle_info(:persist_data, {current, _} = state) do
    Don.create_don(%{amount: current})

    schedule_save()
    {:noreply, state}
  end
end
