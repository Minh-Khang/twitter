defmodule Twitter.Timeline.RetweetsWithComment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "retweets_with_comment" do
    field :body, :string
    belongs_to :tweet, Twitter.Timeline.Tweet
    belongs_to :user, Twitter.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(retweets_with_comment, attrs) do
    retweets_with_comment
    |> cast(attrs, [:body, :tweet_id, :user_id])
    |> validate_required([:body, :tweet_id, :user_id])
  end
end
