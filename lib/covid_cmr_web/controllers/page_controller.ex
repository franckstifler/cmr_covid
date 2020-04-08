defmodule CovidCmrWeb.PageController do
  use CovidCmrWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def stats(conn, _params) do
    render(conn, "stats.html")
  end

  def projections(conn, _params) do
    render(conn, "projections.html")
  end

  def consult(conn, _params) do
    render(conn, "projections.html")
  end
end
