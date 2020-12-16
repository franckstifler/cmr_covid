defmodule CovidCmrWeb.PageControllerLiveTest do
  use CovidCmrWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  # alias CovidCmr.Don

  @statistics CovidCmrWeb.StatisticLive

  test "GET / Test search functionality", %{conn: conn} do
    {:ok, view, html} = live_isolated(conn, @statistics)

    # both country should be in the view at mount
    assert html =~ "Afghanistan"
    assert html =~ "Albania"

    filtered_html =
      view
      |> element("form")
      |> render_change(%{form: %{search: "alb"}})

    # Afghanistan should be gone after filtering
    assert filtered_html =~ "Albania"
    refute filtered_html =~ "Afghanistan"
  end

  test "GET /stats Test counter gets updated", %{conn: conn} do
    {:ok, view, html} = live_isolated(conn, CovidCmrWeb.DashboardLive)

    assert html =~ "Mise a jour en: 60"

    send(view.pid, :counter)

    render(view) =~ "Mise a jour en: 59"
  end

  test "GET /stats Test counter reset to 60 when it's 0", %{conn: conn} do
    {:ok, view, _html} = live_isolated(conn, CovidCmrWeb.DashboardLive)

    for i <- 60..0 do
      assert render(view) =~ "Mise a jour en: #{i}"
      send(view.pid, :counter)
    end

    # Counter should be reset at 60
    assert render(view) =~ "Mise a jour en: 60"
  end

  test "GET /stats should update contributions of SCISC" do
    # Insert a new don
    # Don.create_don(%{amount: 1_000})

    # TODO: Test that the stats are updated after some time
    # send(view.pid, :update)
    # updated_view = render(view)
  end
end
