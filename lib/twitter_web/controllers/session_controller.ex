defmodule TwitterWeb.SessionController do
  use TwitterWeb, :controller
  alias Twitter.{Accounts, Accounts.User, Accounts.Guardian}

  def new(conn, _params) do
    changeset = Accounts.change_user(%User{})
    maybe_user = Guardian.Plug.current_resource(conn)
    if maybe_user do
      redirect(conn, to: Routes.page_path(conn, :index))
    else
      render(conn, "new.html", changeset: changeset)
    end
  end

  def otp(conn, _params) do
    render(conn, "otp.html", changeset: conn)
  end

  def otp_login(conn, %{"otp" => %{"email" => email}}) do
    with  {:ok, _} <- Accounts.email_valid?(email),
          secret <- OneTimePassEcto.Base.gen_secret(32),
          otp <- OneTimePassEcto.Base.gen_totp(secret, [:interval_length, 120]),
          {:ok, _} <- Accounts.insert_otp_token(%{secret: secret, otp: otp})
    do
      IO.inspect(otp, label: "OTP code")
      render(conn, "otp_login.html", email: email)
    else
      {:error, _} -> 
        conn
        |> put_flash(:error, "Email does not exist")
        |> otp(%{})
    end
  end

  def otp_submit(conn, %{"email" => email, "otp" => %{"otp_pass" => otp_pass}}) do
    case Accounts.verify_otp_token(otp_pass, email) do
      {:ok, user}-> 
        conn
        |> Guardian.Plug.sign_in(user)
        |> put_flash(:info, "You've signed in ")
        |> redirect(to: Routes.timeline_path(conn, :index, sort: false))
      {:error, reason} ->   
        conn
        |> put_flash(:error, reason)
        |> render("otp_login.html", email: email)
    end
  end

  def create(conn, %{"session" => %{"email" => email, "password" => password }}) do
    case Accounts.authenticate_user(email, password) do
      {:ok, user} ->
        conn
        |> Guardian.Plug.sign_in(user)
        |> put_flash(:info, "You've signed in ")
        |> redirect(to: Routes.timeline_path(conn, :index, sort: false))

      {:error, _} ->
        conn
        |> put_flash(:error, "Invalid Email or Password")
        |> new(%{})
    end
  end

  def delete(conn, _params) do
    conn
    |> Guardian.Plug.sign_out()
    |> redirect(to: Routes.session_path(conn, :new, %{}))
  end
end
