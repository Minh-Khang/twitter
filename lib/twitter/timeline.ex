defmodule Twitter.Timeline do
	import Ecto.Query
	alias Twitter.Repo
	alias Twitter.Timeline.{Tweet, Like, Reply, Retweet, RetweetsWithComment}

	def list_replies(tweet_id, limit \\ 5) do
		query = 
      from reply in Reply,
        join: user in assoc(reply, :user),
        where: reply.tweet_id == ^tweet_id,
        order_by: [desc: reply.inserted_at],
        limit: ^limit,
        select: %{body: reply.body, user: %{username: user.username}} 

    Repo.all(query)
	end

	def list_tweets(user_id, limit \\ 10) do
		query = 
      from tweet in Tweet,
        where: tweet.user_id == ^user_id,
        order_by: [desc: tweet.inserted_at],
        limit: ^limit,
        select: %{body: tweet.body}

    Repo.all(query)
	end

	def list_following_tweets(sort?, limit \\ 20) do
		query = 
      from tweet in Tweet,
        limit: ^limit,
        preload: [:user, :likes, :retweets, :replies]

    query = case sort? do
    	"true" -> 
    		from tweet in query,
    		join: like in assoc(tweet, :likes), 
    		group_by: tweet.id,
    		order_by: [desc: count(like.id)]

    	"false" ->	
    		from tweet in query,
    		order_by: [desc: tweet.inserted_at]
    end

    Repo.all(query)
	end

	def get_tweet(tweet_id) do 
		Tweet
		|> Repo.get(tweet_id) 
		|> Repo.preload([:user, :likes, :retweets, :replies])
	end

	def create_tweet(user, attrs \\ %{}) do
		user
		|> Ecto.build_assoc(:tweets)
		|> Tweet.changeset(attrs)
		|> Repo.insert()
	end

	def create_like(user, tweet_id, attrs \\ %{}) do
		user
		|> Ecto.build_assoc(:likes, tweet_id: tweet_id)
		|> Like.changeset(attrs)
		|> Repo.insert()
	end

	def create_reply(user, tweet, attrs \\ %{}) do
		user
		|> Ecto.build_assoc(:replies, tweet_id: tweet.id)
		|> Reply.changeset(attrs)
		|> Repo.insert()
	end

	def create_retweet(user, tweet, attrs \\ %{}) do
		user
		|> Ecto.build_assoc(:retweets, tweet_id: tweet.id)
		|> Retweet.changeset(attrs)
		|> Repo.insert()
	end

	def create_retweet_with_comment(user, tweet, attrs \\ %{}) do
		user
		|> Ecto.build_assoc(:retweets_with_comment, tweet_id: tweet.id)
		|> RetweetsWithComment.changeset(attrs)
		|> Repo.insert()
	end	
end