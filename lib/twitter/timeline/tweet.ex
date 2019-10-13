defmodule Twitter.Timeline.Tweet do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tweets" do
    field :body, :string
    has_many :likes, Twitter.Timeline.Like
    has_many :replies, Twitter.Timeline.Reply
    has_many :retweets, Twitter.Timeline.Retweet
    has_many :retweets_with_comment, Twitter.Timeline.RetweetsWithComment
    belongs_to :user, Twitter.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(tweet, attrs) do
    tweet
    |> cast(attrs, [:body])
    |> validate_required([:body])
  end
end
