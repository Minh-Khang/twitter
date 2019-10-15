defmodule Twitter.Timeline do
	import Ecto.Query
	alias Twitter.Repo
	alias Twitter.Timeline.{Tweet, Like, Reply, Retweet, RetweetsWithComment}

	defp create_timeline_query() do
		tweet = 
			from tweet in Tweet,
			join: user in assoc(tweet, :user),
			select: %{id: tweet.id, body: tweet.body, username: user.username, 
							  inserted_at: tweet.inserted_at}

		like_counts = 
			from tweet in subquery(tweet),
			left_join: like in Like, 
			on: tweet.id == like.tweet_id,
			select: %{id: tweet.id, body: tweet.body, username: tweet.username, 
							  inserted_at: tweet.inserted_at, count_like: count(like.id)},
			group_by: [tweet.id, tweet.body, tweet.username, tweet.inserted_at]

		add_retweet_counts = 
			from tweet in subquery(like_counts),
			left_join: retweet in Retweet, 
			on: tweet.id == retweet.tweet_id,
			select: %{id: tweet.id, body: tweet.body, username: tweet.username, 
							  inserted_at: tweet.inserted_at, count_like: tweet.count_like, 
							  count_retweet: count(retweet.id)},
			group_by: [tweet.id, tweet.body, tweet.username, tweet.inserted_at, tweet.count_like]

		add_reply_counts = 
			from tweet in subquery(add_retweet_counts),
			left_join: reply in Reply, 
			on: tweet.id == reply.tweet_id,
			select: %{id: tweet.id, body: tweet.body, username: tweet.username, 
							  inserted_at: tweet.inserted_at, count_like: tweet.count_like, 
							  count_retweet: tweet.count_retweet, count_reply: count(reply.id)},
			group_by: [tweet.id, tweet.body, tweet.username, tweet.inserted_at, tweet.count_like, 
								 tweet.count_retweet]

		add_retweets_column = 
			from tweet in subquery(add_reply_counts),
			select: %{id: tweet.id, body: tweet.body, username: tweet.username, 
							  inserted_at: tweet.inserted_at, count_like: tweet.count_like, 
							  count_retweet: tweet.count_retweet, count_reply: tweet.count_reply, 
							  retweet_by: "", retweet_id: 0}

		retweets = 
			from retweet in Retweet,
			join: user in assoc(retweet, :user),
			select: %{id: retweet.id, tweet_id: retweet.tweet_id, username: user.username, inserted_at: retweet.inserted_at}

		retweets_all = 
			from tweet in subquery(add_reply_counts),
			join: retweet in subquery(retweets), 
			on: tweet.id == retweet.tweet_id,
			select: %{id: tweet.id, body: tweet.body, username: tweet.username, 
							  inserted_at: retweet.inserted_at, count_like: tweet.count_like, 
							  count_retweet: tweet.count_retweet, count_reply: tweet.count_reply, 
							  retweet_by: retweet.username, retweet_id: retweet.id}

		union_all(add_retweets_column, ^retweets_all)
	end

	def list_replies(_tweet_id, _limit \\ 5) do
		
	end

	def list_tweets(_user_id, _limit \\ 10) do
		
	end

	def list_following_tweets(sort?, limit \\ 20) do
		query = create_timeline_query()

		query = 
			case sort? do
				"true" -> 
					from tweet in subquery(query),
					order_by: [desc: tweet.count_like]
				"false" -> 
					from tweet in subquery(query),
					order_by: [desc: tweet.inserted_at]
			end

		Repo.all(
			from tweet in subquery(query),
      limit: ^limit)
	end

	def get_updated_tweet(tweet_id) do 
		query = create_timeline_query()

		query = 
			from tweet in subquery(query),
			where: tweet.id == ^tweet_id

		Repo.all(from tweet in subquery(query))
		|> IO.inspect(label: "get_updated_tweet")
	end

	def get_updated_retweet(tweet_id, retweet_id) do 
		query = create_timeline_query()

		query = 
			from tweet in subquery(query),
			where: tweet.id == ^tweet_id and tweet.retweet_id == ^retweet_id

		Repo.all(from tweet in subquery(query))
		|> IO.inspect(label: "get_updated_retweet")
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

	def create_reply(user, tweet_id, attrs \\ %{}) do
		user
		|> Ecto.build_assoc(:replies, tweet_id: tweet_id)
		|> Reply.changeset(attrs)
		|> Repo.insert()
	end

	def create_retweet(user, tweet_id, attrs \\ %{}) do
		user
		|> Ecto.build_assoc(:retweets, tweet_id: tweet_id)
		|> Retweet.changeset(attrs)
		|> Repo.insert()
		|> IO.inspect(label: "create_retweet")
	end

	def create_retweet_with_comment(user, tweet, attrs \\ %{}) do
		user
		|> Ecto.build_assoc(:retweets_with_comment, tweet_id: tweet.id)
		|> RetweetsWithComment.changeset(attrs)
		|> Repo.insert()
	end	
end