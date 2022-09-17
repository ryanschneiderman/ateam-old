class PostsChannel < ApplicationCable::Channel
  def subscribed
  	stream_from "posts_channel_#{params[:season_id]}"
  end

  def receive(data)
  	if data["trigger_update"]
  		ActionCable.server.broadcast("posts_channel_#{params[:season_id]}", {trigger_update: true})
    elsif data["result"]
      ActionCable.server.broadcast("posts_channel_#{params[:season_id]}", {post: data["result"]})
    end

  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
