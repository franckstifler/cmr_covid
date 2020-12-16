defmodule CovidCmrWeb.PageControllerTest do
  use CovidCmrWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert document = html_response(conn, 200)
    assert document =~ "Total Cases"
    assert document =~ "Albania"
  end

  test "GET /stats", %{conn: conn} do
    conn = get(conn, "/stats")
    assert document = html_response(conn, 200)
    assert document =~ "OBJECTIF ATTEINT / OBJECTIVE ATTAINED"
    assert document =~ "Dons Par Heure"
    assert document =~ "Dons Par Jour"
  end

  test "GET /projections", %{conn: conn} do
    conn = get(conn, "/projections")

    assert document = html_response(conn, 200)
    assert document =~ "<th>Target €</th>"
    assert document =~ "<th>Target FCFA</th>"
    assert document =~ "<th>Estimation J/H</th>"
  end

  test "GET /consult", %{conn: conn} do
    conn = get(conn, "/consult")
    assert html_response(conn, 200) =~ "This page is still in development"
  end
end
