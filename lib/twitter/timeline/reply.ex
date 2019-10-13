defmodule Twitter.Timeline.Reply do
  use Ecto.Schema
  import Ecto.Changeset

  schema "replies" do
    field :body, :string
    belongs_to :tweet, Twitter.Timeline.Tweet
    belongs_to :user, Twitter.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(reply, attrs) do
    reply
    |> cast(attrs, [:body, :tweet_id, :user_id])
    |> validate_required([:body, :tweet_id, :user_id])
  end
end
