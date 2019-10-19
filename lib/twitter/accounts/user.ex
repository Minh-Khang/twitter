defmodule Twitter.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, Twitter.Accounts.EmailType
    field :hash_password, :string
    field :username, :string

    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true

    has_many :tweets, Twitter.Timeline.Tweet
    has_many :likes, Twitter.Timeline.Like
    has_many :replies, Twitter.Timeline.Reply
    has_many :retweets, Twitter.Timeline.Retweet
    has_many :retweets_with_comment, Twitter.Timeline.RetweetsWithComment

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :username])
    |> validate_required([:email, :username])
    |> validate_length(:email, min: 3, max: 100)
    |> unique_constraint(:email)
    |> validate_email
  end

  def registration_changeset(user, attrs) do
    user
    |> changeset(attrs)
    |> cast(attrs, [:password])
    |> validate_required([:password])
    |> validate_confirmation(:password)
    |> validate_length(:password, min: 6, max: 100)
    |> encrypt_password
  end

  defp encrypt_password(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(changeset, :hash_password, Argon2.hash_pwd_salt(password))

      _ ->
        changeset
    end
  end

  defp validate_email(changeset) do
    validate_change(changeset, :email, fn :email, email ->
      case EmailChecker.valid?(email, [EmailChecker.Check.Format]) do
        true -> []
        false -> [email: "Please enter valid email address"]
      end
    end)
  end
end
