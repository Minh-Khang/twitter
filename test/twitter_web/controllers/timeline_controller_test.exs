defmodule TwitterWeb.TimelineControllerTest do
	use TwitterWeb.ConnCase

	alias Twitter.Timeline
	alias Twitter.Accounts.Guardian
	alias Twitter.Repo

	test "requires user authentication on all actions", %{conn: conn} do
    Enum.each([
      get(conn, Routes.timeline_path(conn, :index), sort: "false"),
      get(conn, Routes.timeline_path(conn, :new)),
      post(conn, Routes.timeline_path(conn, :create), %{tweet: %{body: "some body"}}),
      post(conn, Routes.timeline_path(conn, :like, tweet_id: 1)),
      post(conn, Routes.timeline_path(conn, :retweet, tweet_id: 1))
    ], fn conn ->
      assert text_response(conn, 401) =~ "unauthenticated"
      assert conn.halted
    end)
  end

	setup %{conn: conn} = config do
    if username = config[:login_as] do
      user = user_fixture(username: username)
  		conn = Guardian.Plug.sign_in(conn, user)
      {:ok, conn: conn, user: user}
    else
      :ok
    end
  end

	@tag login_as: "lmk"
	test "index", %{conn: conn, user: _user} do
		timeline_fixture()
		tweets = Timeline.list_following_tweets("false")
		conn = get(conn, Routes.timeline_path(conn, :index), sort: "false")

	  assert tweets == conn.assigns.tweets
	  assert html_response(conn, 200) =~ "Listing Tweets"
	end

	@tag login_as: "lmk"
	test "new", %{conn: conn, user: _user} do
		conn = get(conn, Routes.timeline_path(conn, :new))

		assert html_response(conn, 200) =~ "Tweet"
	end

	@tag login_as: "lmk"
	test "create", %{conn: conn, user: user} do
		conn = post(conn, Routes.timeline_path(conn, :create), %{tweet: %{body: "some body"}})
		user = Repo.preload(user, :tweets)

		assert redirected_to(conn) =~ Routes.timeline_path(conn, :index, sort: false)
		assert hd(user.tweets).body == "some body"
	end

	@tag login_as: "lmk"
	test "like", %{conn: conn, user: _user} do
		attrs = timeline_fixture()
		random_tweet = Enum.at(attrs, 1) |> Enum.take_random(1) |> hd

		tweets_before = Timeline.get_updated_tweet(random_tweet.id)
		_conn = post(conn, Routes.timeline_path(conn, :like, tweet_id: random_tweet.id))
		tweets_after = Timeline.get_updated_tweet(random_tweet.id)

		assert length(tweets_before) == length(tweets_after)

		pair_tweets = Enum.zip(tweets_before, tweets_after)

		for pair_tweet <- pair_tweets do
			{tweet_before, tweet_after} = pair_tweet

			assert tweet_before.id 							== tweet_after.id
			assert tweet_before.retweet_id 			== tweet_after.retweet_id
			assert tweet_before.count_like + 1 	== tweet_after.count_like 
		end
	end

	@tag login_as: "lmk"
	test "retweet", %{conn: conn, user: _user} do
		attrs = timeline_fixture()
		random_tweet = Enum.at(attrs, 1) |> Enum.take_random(1) |> hd

		tweets_before = Timeline.get_updated_tweet(random_tweet.id)
		_conn = post(conn, Routes.timeline_path(conn, :retweet, tweet_id: random_tweet.id))
		tweets_after = Timeline.get_updated_tweet(random_tweet.id)

		assert length(tweets_before) + 1 == length(tweets_after)

		pair_tweets = Enum.zip(tweets_before, tweets_after)

		for pair_tweet <- pair_tweets do
			{tweet_before, tweet_after} = pair_tweet

			assert tweet_before.id 									== tweet_after.id
			# assert tweet_before.retweet_id 					== tweet_after.retweet_id
			assert tweet_before.count_retweet + 1 	== tweet_after.count_retweet 
		end
	end
end