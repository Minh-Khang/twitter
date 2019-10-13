defmodule Twitter.Timeline do
	import Ecto.Query
	alias Twitter.Repo
	alias Twitter.Timeline.{Tweet, Like, Reply, Retweet, RetweetsWithComment}

	def get_likes(tweet_id) do
		query = 
      from like in Like,
        where: like.tweet_id == ^tweet_id,
        select: count(like.id)

    Repo.all(query)
	end

	def get_retweets(tweet_id) do
		query = 
      from retweet in Retweet,
        where: retweet.tweet_id == ^tweet_id,
        select: count(retweet.id)

    Repo.all(query)
	end

	def get_replies(tweet_id) do
		query = 
      from reply in Reply,
        where: reply.tweet_id == ^tweet_id,
        select: count(reply.id)

    Repo.all(query)
	end

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

	def show_relate_tweets(limit \\ 20) do
		query = 
      from tweet in Tweet,
        order_by: [desc: tweet.inserted_at],
        limit: ^limit,
        select: %{body: tweet.body}

    Repo.all(query)
	end

	def create_tweet(user, attrs \\ %{}) do
		user
		|> Ecto.build_assoc(:tweets)
		|> Tweet.changeset(attrs)
		|> Repo.insert()
	end

	def create_like(user, tweet, attrs \\ %{}) do
		user
		|> Ecto.build_assoc(:likes, tweet_id: tweet.id)
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