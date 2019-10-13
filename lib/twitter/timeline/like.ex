defmodule Twitter.Timeline.Like do
  use Ecto.Schema
  import Ecto.Changeset

  schema "likes" do
    belongs_to :tweet, Twitter.Timeline.Tweet
    belongs_to :user, Twitter.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(like, attrs) do
    like
    |> cast(attrs, [:tweet_id, :user_id])
    |> validate_required([:tweet_id, :user_id])
  end
end
