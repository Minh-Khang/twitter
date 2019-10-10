defmodule Twitter.Accounts do
  alias Twitter.Repo
  alias Twitter.Accounts.User

  def register(params), do: %User{} |> User.registration_changeset(params) |> Repo.insert
end
