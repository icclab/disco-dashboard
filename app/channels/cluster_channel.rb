# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
#
# ClusterChannel is used to create subscription between client and server.
# After subscription, channel can run some methods related to the subscribed user.
class ClusterChannel < ApplicationCable::Channel
  # Including ClusterHelper since it contains 'update_cluster' method which is used by this channel
  include ClusterHelper

  # Periodically (every 30 seconds) check for updates on cluster states
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
