defmodule Twitter.Accounts do
  import Ecto.Query
  alias Twitter.Repo
  alias Twitter.Accounts.User

  def register(params), do: %User{} |> User.registration_changeset(params) |> Repo.insert

  def authenticate_user(email, password) do
    query = from u in User, where: u.email == ^email
    case Repo.one(query) do
      nil ->
        Argon2.no_user_verify()
        {:error, :invalid_credentials}
      user ->
        if Argon2.verify_pass(password, user.hash_password) do
          {:ok, user}
        else
          {:error, :invalid_credentials}
        end
    end
  end

  def get_user!(id), do: Repo.get!(User, id)
  def change_user(%User{} = user), do: User.changeset(user, %{})
end
