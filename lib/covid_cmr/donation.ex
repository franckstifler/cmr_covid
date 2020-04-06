defmodule Donation do
  use GenServer

  def start_link(_opts) do
    current = 0
    target = 1_000_000
    GenServer.start_link(__MODULE__, {current, target}, name: __MODULE__)
  end

  def init(state) do
    schedule_fetch()
    {:ok, state}
  end

  def get_new_data do
    GenServer.call(__MODULE__, :get, 10_000)
  end

  def schedule_fetch() do
    Process.send_after(self(), :get_new_data, 40 * 1000)
  end

  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end

  def handle_info(:get_new_data, state) do
    target = 1_000_000

    case get_current_status() do
      {:ok, current} ->
        schedule_fetch()
        {:noreply, {current, target}}

      _ ->
        schedule_fetch()
        {:noreply, state}
    end
  end

  defp get_current_status() do
    case HTTPoison.get("https://cameroonsurvival.org/fr/dons/") do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, document} =
          body
          |> Floki.parse_document()

        [current, _target] =
          document
          |> Floki.attribute("span", "data-amounts")
          |> Enum.map(fn x ->
            Jason.decode!(x)
          end)

        current = String.replace(current["EUR"], "€", "") |> String.replace(".", "")

        case Float.parse(current) do
          {current, _} ->
            {:ok, current}

          _ ->
            {:error, :parsing_failed}
        end

      _ ->
        {:error, :failed_fetch}
    end
  end
end
