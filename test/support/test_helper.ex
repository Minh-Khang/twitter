defmodule Twitter.TestHelper do
  alias Twitter.{Accounts, Timeline}

	@valid_user_attrs %{email: "some@email.com", username: "some username", password: "some password", password_confirmation: "some password"}

	def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(@valid_user_attrs)
      |> Accounts.register()

    user
  end

  def tweet_fixture(user, attrs \\ %{}) do
    {:ok, tweet} = Timeline.create_tweet(user, attrs |> Enum.into(%{body: "some body"}))

    tweet
  end

  def timeline_fixture do
    user_list = for _ <- 1..5 do
      user_fixture(%{email: Faker.UUID.v4 <> Faker.Internet.email, username: Faker.Internet.user_name})
    end

    tweet_list = for _ <- 1..10 do
      user_list |> Enum.take_random(1) |> hd |> tweet_fixture(body: Faker.Lorem.paragraph)
    end

    like_list = for _ <- 1..100 do
      user = user_list |> Enum.take_random(1) |> hd
      tweet = tweet_list |> Enum.take_random(1) |> hd
      Timeline.create_like(user, tweet.id)
    end

    retweet_list = for _ <- 1..10 do
      user = user_list |> Enum.take_random(1) |> hd
      tweet = tweet_list |> Enum.take_random(1) |> hd
      Timeline.create_retweet(user, tweet.id)
    end

    reply_list = for _ <- 1..10 do
      user = user_list |> Enum.take_random(1) |> hd
      tweet = tweet_list |> Enum.take_random(1) |> hd
      Timeline.create_reply(user, tweet.id, %{body: Faker.Lorem.paragraph})
    end

    [user_list, tweet_list, like_list, retweet_list, reply_list]
  end

  # @secret OneTimePassEcto.Base.gen_secret(32)
  # @valid_otp_attrs %{secret: @secret, otp: OneTimePassEcto.Base.gen_totp(@secret, [{:interval_length, 120}])}

  # def otp_fixture(attrs \\ %{}) do
  #   {:ok, onetimepass} = 
  #     attrs
  #     |> Enum.into(@valid_otp_attrs)
  #     |> Accounts.insert_otp_token

  #   onetimepass
  # end

end