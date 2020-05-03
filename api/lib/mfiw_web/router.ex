defmodule MfiwWeb.Router do
  use MfiwWeb, :router

  # This is obsolete, but some of these plugs may
  # be useful for the API - need to do more research.
  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", MfiwWeb do
    pipe_through :api

    resources "/ingredients", IngredientController, except: [:new, :edit]
  end
end
