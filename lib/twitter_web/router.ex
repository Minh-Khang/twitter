defmodule TwitterWeb.Router do
  use TwitterWeb, :router

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

  pipeline :auth do
    plug Twitter.Accounts.Pipeline
  end

  pipeline :ensure_auth do
    plug Guardian.Plug.EnsureAuthenticated
  end

  scope "/", TwitterWeb do
    pipe_through [:browser, :auth]

    resources "/registration", RegistrationController, only: [:new, :create]
    resources "/sessions", SessionController, only: [:new, :create]
    delete "/sign_out", SessionController, :delete
    get "/", PageController, :index
  end

  scope "/", TwitterWeb do
    pipe_through [:browser, :auth, :ensure_auth]
    
  end

  # Other scopes may use custom stacks.
  # scope "/api", TwitterWeb do
  #   pipe_through :api
  # end
end
