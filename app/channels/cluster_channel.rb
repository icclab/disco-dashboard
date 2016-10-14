# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class ClusterChannel < ApplicationCable::Channel
  def subscribed
    # stream_from "some_channel"
    puts "====================================================================="
    puts "                    Subscribed: user_id is #{user_id}"
    puts "====================================================================="
    stream_from "cluster_#{user_id}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
