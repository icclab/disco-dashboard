# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class ClusterChannel < ApplicationCable::Channel

  include ClusterHelper

  # Periodically (every 30 seconds) updates cluster states
  periodically every: 30 do
    update_clusters(user_id)
  end

  # Called when channel is subscribed.
  # Starts streaming from selected stream and updates all user's clusters.
  def subscribed
    # stream_from "some_channel"
    stream_from "user_#{user_id}"
    update_clusters user_id
  end

  # Called when user channel unsubscribed.
  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

end
