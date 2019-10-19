defmodule Twitter.AccountsTest do
  use Twitter.DataCase
  alias Twitter.Accounts
  alias Twitter.Accounts.{User, Onetimepass}

  @valid_user_attrs %{email: "some@email.com", username: "some username", password: "some password", password_confirmation: "some password"}
  @invalid_user_attrs %{email: nil, username: nil, password: nil, password_confirmation: nil}

  describe "registration" do
    test "valid user attrs" do
      assert {:ok, %User{} = user} = Accounts.register(@valid_user_attrs)
      assert user.email == "some@email.com"
      assert user.username == "some username"
      assert Argon2.verify_pass("some password", user.hash_password)
    end

    test "invalid user attrs" do
      assert {:error, %Ecto.Changeset{} = changeset} = Accounts.register(@invalid_user_attrs)
      refute changeset.valid?
    end

    test "wrong type email" do
      attrs = Map.put(@valid_user_attrs, :email, "wrong")

      assert {:error, %Ecto.Changeset{} = changeset} = Accounts.register(attrs)
      assert {:email, {"Please enter valid email address", []}} in changeset.errors
    end

    test "email must be at most 100 characters long" do
      attrs = Map.put(@valid_user_attrs, :email, String.duplicate("a", 91) <> "@email.com")
    
      assert {:error, %Ecto.Changeset{} = changeset} = Accounts.register(attrs)
      assert {:email, {"should be at most %{count} character(s)",
               [count: 100, validation: :length, kind: :max, type: :string]}} in changeset.errors
    end

    test "unmatch password" do
      attrs = Map.put(@valid_user_attrs, :password_confirmation, "unmatch")

      assert {:error, %Ecto.Changeset{} = changeset} = Accounts.register(attrs)
      assert {:password_confirmation, {"does not match confirmation", [validation: :confirmation]}} in changeset.errors
    end

    test "password must be at least six characters long" do
      attrs = Map.put(@valid_user_attrs, :password, "123")
      attrs = Map.put(attrs, :password_confirmation, "123")
    
      assert {:error, %Ecto.Changeset{} = changeset} = Accounts.register(attrs)
      assert {:password, {"should be at least %{count} character(s)",
               [count: 6, validation: :length, kind: :min, type: :string]}} in changeset.errors
    end

    test "password must be at most 100 characters long" do
      attrs = Map.put(@valid_user_attrs, :password, String.duplicate("a", 101))
      attrs = Map.put(attrs, :password_confirmation, String.duplicate("a", 101))
    
      assert {:error, %Ecto.Changeset{} = changeset} = Accounts.register(attrs)
      assert {:password, {"should be at most %{count} character(s)",
               [count: 100, validation: :length, kind: :max, type: :string]}} in changeset.errors
    end
  end

  describe "authenticate" do
    test "a valid email and password" do
      new_user = user_fixture(%{password: "password", password_confirmation: "password"})

      assert {:ok, %User{} = user} = Accounts.authenticate_user(new_user.email, "password")
      assert user.id == new_user.id
      assert user.email == new_user.email
      assert user.hash_password == new_user.hash_password
    end

    test "a not found user" do
      assert {:error, :invalid_credentials} = Accounts.authenticate_user("some@email.com", "password")
    end

    test "password mismatch" do
      assert {:error, :invalid_credentials} = Accounts.authenticate_user("some@email.com", "wrong")
    end
  end

  describe "email" do
    test "exist in database" do
      new_user = user_fixture()

      assert {:ok, %User{} = user} = Accounts.email_valid?(new_user.email)
    end
    test "not exist in database" do
      assert {:error, :invalid_credentials} = Accounts.email_valid?("not@exist.com")
    end
  end

  describe "user" do
    test "get_user!/1 returns the user with given id" do
      new_user = user_fixture()
      user = Accounts.get_user!(new_user.id)

      assert %User{} = user
      assert user.id == new_user.id
      assert user.email == new_user.email
      assert user.username == new_user.username
      assert user.hash_password == new_user.hash_password
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end

  describe "otp token" do
    @secret OneTimePassEcto.Base.gen_secret(32)
    @valid_otp_attrs %{secret: @secret, otp: OneTimePassEcto.Base.gen_totp(@secret, [{:interval_length, 120}])}
    @invalid_otp_attrs %{secret: nil, otp: nil}

    def otp_fixture(attrs \\ %{}) do
      {:ok, onetimepass} = 
        attrs
        |> Enum.into(@valid_otp_attrs)
        |> Accounts.insert_otp_token

      onetimepass
    end

    test "insert_otp_token/1 with valid attrs" do
      assert {:ok, %Onetimepass{} = onetimepass} = Accounts.insert_otp_token(@valid_otp_attrs)
    end

    test "insert_otp_token/1 with invalid attrs" do
      assert {:error, %Ecto.Changeset{} = changeset} = Accounts.insert_otp_token(@invalid_otp_attrs)
      refute changeset.valid?
    end

    test "verify_otp_token/2 a valid attrs" do
      new_otp = otp_fixture()
      new_user = user_fixture()

      assert {:ok, %User{} = user} = Accounts.verify_otp_token(new_otp.otp, new_user.email)
      assert user.id == new_user.id
      assert user.email == new_user.email
      assert user.username == new_user.username
      assert user.hash_password == new_user.hash_password

      # remove logined overtime otp
      onetimepass = Repo.get_by(Onetimepass, otp: new_otp.otp)
      assert is_nil(onetimepass) 

      #remove all overtime otp
      onetimepasses = Repo.all(Onetimepass) 
      for item <- onetimepasses do
        assert item.inserted_at > Ecto.Query.API.datetime_add(NaiveDateTime.utc_now, -120, "second")
      end
    end

    test "verify_otp_token/2 a overtime otp" do
      new_otp = otp_fixture(%{otp: OneTimePassEcto.Base.gen_totp(@secret)})
      new_user = user_fixture()

      assert {:error, :invalid_otp} = Accounts.verify_otp_token(new_otp.otp, new_user.email)
    end

    test "verify_otp_token/2 a invalid otp" do
      new_user = user_fixture()

      assert {:error, :invalid_credentials} = Accounts.verify_otp_token("invalid", new_user.email)
    end
  end
end
