defmodule TwitterWeb.TimelineController do
	use TwitterWeb, :controller
	alias Twitter.Timeline

	def index(conn, %{"sort" => sort}) do
		tweets = Timeline.list_following_tweets(sort)
		render(conn, "index.html", tweets: tweets)
	end

	def new(conn, _params) do
		render(conn, "tweet.html", changeset: conn)
	end

	def create(conn, %{"tweet" => tweet}) do
		user = Guardian.Plug.current_resource(conn)
		case Timeline.create_tweet(user, tweet) do
		 	{:ok, _} -> 
		 		conn
		 		|> put_flash(:info, "tweet")
        |> redirect(to: Routes.timeline_path(conn, :index, sort: false))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
		 end 
	end

	def like(conn, %{"retweet_id" => _retweet_id, "tweet_id" => tweet_id}) do
		user = Guardian.Plug.current_resource(conn)
		{tweet_id, _} = Integer.parse(tweet_id)
		with 	{:ok, _like} <- Timeline.create_like(user, tweet_id),
					tweets <- Timeline.get_updated_tweet(tweet_id)
		do
			params = for tweet <- tweets do
				html = Phoenix.View.render_to_string(TwitterWeb.TimelineView, "row.html", tweet: tweet, conn: conn)
			  %{html: html, id: "tweet-#{tweet_id}-#{tweet.retweet_id}"}
			end
			json conn, %{params: params}
		end
	end

	def retweet(conn, %{"tweet_id" => tweet_id}) do
		user = Guardian.Plug.current_resource(conn)
		{tweet_id, _} = Integer.parse(tweet_id)

		with 	{:ok, retweet} <- Timeline.create_retweet(user, tweet_id),
					tweet <- Timeline.get_updated_retweet(tweet_id, retweet.id)
		do
			html = Phoenix.View.render_to_string(TwitterWeb.TimelineView, "row.html", tweet: hd(tweet), conn: conn)
			json conn, %{html: html, id: "tweet-#{tweet_id}-#{hd(tweet).retweet_id}"}
		end
	end
end