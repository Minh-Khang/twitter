defmodule Twitter.Accounts do
  import Ecto.Query
  alias Twitter.Repo
  alias Twitter.Accounts.User
  alias Twitter.Accounts.Onetimepass

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

  def email_valid?(email) do
    case Repo.get_by(User, email: email) do
      nil ->  {:error, :invalid_credentials}
      user -> {:ok, user}
    end
  end

  def insert_otp_token(params), do: %Onetimepass{} |> Onetimepass.changeset(params) |> Repo.insert
  defp delete_overtime_otp_token() do 
    query = from u in Onetimepass, where: u.inserted_at <= datetime_add(^NaiveDateTime.utc_now, -120, "second")
    Repo.all(query) |> IO.inspect(label: "LMK")
    Repo.delete_all(query)
  end

  defp delete_logined_token(onetimepass), do: Repo.delete(onetimepass)

  def verify_otp_token(token, email) do
    delete_overtime_otp_token()

    with  onetimepass when not is_nil(onetimepass) <- Repo.get_by(Onetimepass, otp: token),
          number when is_integer(number) <- OneTimePassEcto.Base.check_totp(token, onetimepass.secret, [interval_length: 120])
    do
      delete_logined_token(onetimepass)
      user = Repo.get_by(User, email: email)
      {:ok, user}
    else
      nil -> {:error, :invalid_credentials}
      false -> {:error, :invalid_otp}
    end
  end

  def get_user!(id), do: Repo.get!(User, id)
  def change_user(%User{} = user), do: User.changeset(user, %{})
end