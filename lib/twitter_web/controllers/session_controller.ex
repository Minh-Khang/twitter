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
    |> redirect(to: Routes.session_path(conn, :new))
  end
end
