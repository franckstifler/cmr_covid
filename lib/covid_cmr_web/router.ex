defmodule CovidCmrWeb.Router do
  use CovidCmrWeb, :router
  import Phoenix.LiveView.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {CovidCmrWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", CovidCmrWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/stats", PageController, :stats
    get "/projections", PageController, :projections
    get "/consult", PageController, :consult
  end

  # Other scopes may use custom stacks.
  # scope "/api", CovidCmrWeb do
  #   pipe_through :api
  # end
end
