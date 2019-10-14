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
        |> redirect(to: Routes.timeline_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
		 end 
	end

	def like(conn, %{"id" => tweet_id}) do
		user = Guardian.Plug.current_resource(conn)
		{id, _} = Integer.parse(tweet_id)
		with 	{:ok, _like} <- Timeline.create_like(user, id),
					tweet <- Timeline.get_tweet(tweet_id)
		do
			html = Phoenix.View.render_to_string(TwitterWeb.TimelineView, "row.html", tweet: tweet, conn: conn)
			json conn, %{html: html, tweet_id: "#tweet-#{tweet_id}"}
		end
	end
end