# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Twitter.Repo.insert!(%Twitter.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Twitter.{Accounts, Timeline}

user_list = for _ <- 1..5 do
	{:ok, user } = Accounts.register(%{email: Faker.Internet.email, username: Faker.Internet.user_name, password: "password", password_confirmation: "password"})
	user
end

tweet_list = for _ <- 1..10 do
	{:ok, tweet} = user_list |> Enum.take_random(1) |> hd |> Timeline.create_tweet(%{body: Faker.Lorem.paragraph})
	tweet
end

for _ <- 1..100 do
	user = user_list |> Enum.take_random(1) |> hd
	tweet = tweet_list |> Enum.take_random(1) |> hd
	Timeline.create_like(user, tweet.id)
end

for _ <- 1..10 do
	user = user_list |> Enum.take_random(1) |> hd
	tweet = tweet_list |> Enum.take_random(1) |> hd
	Timeline.create_retweet(user, tweet.id)
end

for _ <- 1..10 do
	user = user_list |> Enum.take_random(1) |> hd
	tweet = tweet_list |> Enum.take_random(1) |> hd
	Timeline.create_reply(user, tweet.id, %{body: Faker.Lorem.paragraph})
end
