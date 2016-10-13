# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class ClusterChannel < ApplicationCable::Channel
  def subscribed
    # stream_from "some_channel"
    stream_from "cluster_#{user_id}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
