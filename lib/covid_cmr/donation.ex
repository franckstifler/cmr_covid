defmodule Donation do
  use GenServer

  def start_link(_opts) do
    current = 0
    target = 1_000_000
    GenServer.start_link(__MODULE__, {current, target}, name: __MODULE__)
  end

  def init(state) do
    {:ok, state}
  end

  def get_new_data do
    GenServer.call(__MODULE__, :get)
  end

  def handle_call(:get, _from, state) do
    case get_current_status() do
      {a, b} ->
        {:reply, {a, b}, {a, b}}

      _ ->
        {:reply, state, state}
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

        {current, _} = Float.parse(current)

        {current, 1_000_000}

      {:error, _} ->
        {:error, 0}
    end
  end
end
