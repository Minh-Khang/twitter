defmodule Twitter.TimelineTest do
	use Twitter.DataCase
	alias Twitter.{Repo, Timeline}
	alias Twitter.Timeline.{Tweet, Like, Reply, Retweet, RetweetsWithComment}

	@valid_body_attrs %{body: "some body"}
	@invalid_body_attrs %{body: nil}

  describe "tweet" do
  	test "valid attrs" do
	  	user = user_fixture()

	  	assert {:ok, %Tweet{} = tweet} = Timeline.create_tweet(user, @valid_body_attrs)
	  	tweet = Repo.preload(tweet, :user)

	  	assert tweet.body == "some body"
	  	assert tweet.user.id == user.id
	  	assert tweet.user.email == user.email
	  	assert tweet.user.username == user.username
	  	assert tweet.user.hash_password == user.hash_password
	  end

	  test "invalid attrs" do
	  	user = user_fixture()

	  	assert {:error, %Ecto.Changeset{} = changeset} = Timeline.create_tweet(user, @invalid_body_attrs)
	  	refute changeset.valid?
	  end
  end

	test "like with valid attrs" do
  	user = user_fixture(email: Faker.UUID.v4 <> Faker.Internet.email)
  	tweet = tweet_fixture(user_fixture())

  	assert {:ok, %Like{} = like} = Timeline.create_like(user, tweet.id)
  	like = Repo.preload(like, [:user, :tweet])

  	assert like.user.id == user.id
  	assert like.user.email == user.email
  	assert like.user.username == user.username
  	assert like.user.hash_password == user.hash_password

  	assert like.tweet.id == tweet.id
  	assert like.tweet.body == tweet.body
  end
  
  test "retweet with valid attrs" do
  	user = user_fixture(email: Faker.UUID.v4 <> Faker.Internet.email)
  	tweet = tweet_fixture(user_fixture())

  	assert {:ok, %Retweet{} = retweet} = Timeline.create_retweet(user, tweet.id)
  	retweet = Repo.preload(retweet, [:user, :tweet])

  	assert retweet.user.id == user.id
  	assert retweet.user.email == user.email
  	assert retweet.user.username == user.username
  	assert retweet.user.hash_password == user.hash_password

  	assert retweet.tweet.id == tweet.id
  	assert retweet.tweet.body == tweet.body
  end

	describe "reply" do
		test "with valid attrs" do
	  	user = user_fixture(email: Faker.UUID.v4 <> Faker.Internet.email)
	  	tweet = tweet_fixture(user_fixture())

	  	assert {:ok, %Reply{} = reply} = Timeline.create_reply(user, tweet.id, @valid_body_attrs)
	  	reply = Repo.preload(reply, [:user, :tweet])

	  	assert reply.user.id == user.id
	  	assert reply.user.email == user.email
	  	assert reply.user.username == user.username
	  	assert reply.user.hash_password == user.hash_password

	  	assert reply.tweet.id == tweet.id
	  	assert reply.tweet.body == tweet.body

	  	assert reply.body == "some body"
	  end

	  test "with invalid attrs" do
	  	user = user_fixture(email: Faker.UUID.v4 <> Faker.Internet.email)
	  	tweet = tweet_fixture(user_fixture())

	  	assert {:error, %Ecto.Changeset{} = changeset} = Timeline.create_reply(user, tweet.id, @invalid_body_attrs)
	  	refute changeset.valid?
	  end
	end

	describe "retweet with comment" do
		test "with valid attrs" do
	  	user = user_fixture(email: Faker.UUID.v4 <> Faker.Internet.email)
	  	tweet = tweet_fixture(user_fixture())

	  	assert {:ok, %RetweetsWithComment{} = retweets_with_comment} = Timeline.create_retweet_with_comment(user, tweet.id, @valid_body_attrs)
	  	retweets_with_comment = Repo.preload(retweets_with_comment, [:user, :tweet])

	  	assert retweets_with_comment.user.id == user.id
	  	assert retweets_with_comment.user.email == user.email
	  	assert retweets_with_comment.user.username == user.username
	  	assert retweets_with_comment.user.hash_password == user.hash_password

	  	assert retweets_with_comment.tweet.id == tweet.id
	  	assert retweets_with_comment.tweet.body == tweet.body

	  	assert retweets_with_comment.body == "some body"
	  end

	  test "with invalid attrs" do
	  	user = user_fixture(email: Faker.UUID.v4 <> Faker.Internet.email)
	  	tweet = tweet_fixture(user_fixture())

	  	assert {:error, %Ecto.Changeset{} = changeset} = Timeline.create_retweet_with_comment(user, tweet.id, @invalid_body_attrs)
	  	refute changeset.valid?
	  end
	end
	
	test "list_following_tweets return tweets, like count, retweet count, reply count" do
		timeline_fixture()
		tweets = Timeline.list_following_tweets("false")
		original_tweets = Enum.filter(tweets, fn x -> String.equivalent?(x.retweet_by,"") end)

		assert length(tweets) == 20 # tweets + retweets
		assert Enum.sum(for tweet <- original_tweets, do: tweet.count_like) == 100 # total like click
		assert Enum.sum(for tweet <- original_tweets, do: tweet.count_retweet) == 10 # total retweet
		assert Enum.sum(for tweet <- original_tweets, do: tweet.count_reply) == 10 # total reply
	end

	test "get_updated_tweet return tweet with like count, retweet count, reply count" do
		attrs = timeline_fixture()
		user = Enum.at(attrs, 0) |> Enum.take_random(1) |> hd
		tweet = Enum.at(attrs, 1) |> Enum.take_random(1) |> hd
		{:ok, _} = Timeline.create_like(user, tweet.id)
		tweets = Timeline.get_updated_tweet(tweet.id)

		assert length(Enum.uniq(for tweet <- tweets, do: tweet.id)) == 1 # has same tweet id
		assert length(Enum.uniq(for tweet <- tweets, do: tweet.count_like)) == 1 # has same like
		assert length(Enum.uniq(for tweet <- tweets, do: tweet.count_retweet)) == 1 # has same retweet
		assert length(Enum.uniq(for tweet <- tweets, do: tweet.count_reply)) == 1 # has same reply
		assert length(Enum.uniq(for tweet <- tweets, do: tweet.username)) == 1 # has same username
	end
	
end