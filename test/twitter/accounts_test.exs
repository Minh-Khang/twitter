defmodule Twitter.AccountsTest do
  use Twitter.DataCase
  alias Twitter.Accounts

  describe "registration" do
    alias Twitter.Accounts.User

    @valid_attrs %{email: "some@email.com", username: "some username", password: "some password", password_confirmation: "some password"}
    @invalid_attrs %{email: nil, username: nil, password: nil, password_confirmation: nil}

    test "registration with valid user" do
      assert {:ok, %User{} = user} = Accounts.register(@valid_attrs)
      assert user.email == "some@email.com"
      assert user.username == "some username"
      assert Argon2.verify_pass("some password", user.hash_password) == true
    end

    test "registration with invalid user" do
      assert {:error, %Ecto.Changeset{}} = Accounts.register(@invalid_attrs)
    end
  end
end
