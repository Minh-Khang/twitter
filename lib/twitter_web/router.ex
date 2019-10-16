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
    get "/sessions/otp", SessionController, :otp
    get "/sessions/otp_login", SessionController, :otp_login
    post "/sessions/otp_login", SessionController, :otp_login
    post "/sessions/otp_submit", SessionController, :otp_submit
    delete "/sign_out", SessionController, :delete
    get "/", PageController, :index
  end

  scope "/", TwitterWeb do
    pipe_through [:browser, :auth, :ensure_auth]
    resources "/timeline", TimelineController, only: [:index, :new, :create]
    post "/timeline/like", TimelineController, :like
    post "/timeline/retweet", TimelineController, :retweet
  end

  # Other scopes may use custom stacks.
  # scope "/api", TwitterWeb do
  #   pipe_through :api
  # end
end
