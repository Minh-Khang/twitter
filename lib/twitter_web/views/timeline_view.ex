defmodule TwitterWeb.TimelineView do
	use TwitterWeb, :view

	def is_like?() do
		false
	end

	def is_retweet?() do
		false
	end
end