defmodule Twitter.Timeline.Retweet do
  use Ecto.Schema
  import Ecto.Changeset

  schema "retweets" do
    belongs_to :tweet, Twitter.Timeline.Tweet
    belongs_to :user, Twitter.Accounts.User
    
    timestamps()
  end

  @doc false
  def changeset(retweet, attrs) do
    retweet
    |> cast(attrs, [:tweet_id, :user_id])
    |> validate_required([:tweet_id, :user_id])
  end
end
