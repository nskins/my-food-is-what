defmodule MfiwWeb.Router do
  use MfiwWeb, :router

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

  scope "/", MfiwWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  scope "/api", MfiwWeb do
    pipe_through :api

    resources "/ingredients", IngredientController, except: [:new, :edit]
  end
end
