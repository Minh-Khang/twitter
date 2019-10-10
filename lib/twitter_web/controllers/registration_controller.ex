defmodule TwitterWeb.RegistrationController do
  use TwitterWeb, :controller
  alias Twitter.Accounts

  def new(conn, _params) do
    render(conn, "new.html", changeset: conn)
  end

  def create(conn, %{"params" => registration_params}) do
    case Accounts.register(registration_params) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "You've sign up and sign in")
        |> redirect(to: Routes.page_path(conn, :index))

      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end
