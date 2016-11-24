# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class ClusterChannel < ApplicationCable::Channel

  # Periodically (every 30 seconds) updates cluster states
  periodically :update_clusters, every: 30

  # Called when channel is subscribed.
  # Starts streaming from selected stream and updates all user's clusters.
  def subscribed
    # stream_from "some_channel"
    stream_from "user_#{user_id}"
    update_clusters
  end

  # Called when user channel unsubscribed.
  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  # Method to update current user's clusters.
  # Tries to connect to the clusters using its ip address.
  # When timeout occurs, updates state to "CONNECTION FAILED"
  # Otherwise, if state is changed then updates state to the new state
  def update_clusters
    current_user = User.find(user_id)
    clusters = current_user.clusters.all
    clusters.each do |cluster|
      if cluster[:external_ip]
        state = old_state = cluster[:state]
        ip = IPAddr.new(cluster[:external_ip], Socket::AF_INET).to_s
        url = "http://"+ip+":8084/progress.log"
        uri     = URI.parse(url)
        request = Net::HTTP::Get.new(uri)
        response = nil
        begin
          response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
            http.request(request)
          end

        rescue Net::OpenTimeout
          state = 'CONNECTION_FAILED'
        rescue Errno::ECONNREFUSED

        end

        if response && response.code == "200"
          if response.body.to_i == 1
            state = 'READY'
          else
            state = 'INSTALLING_FRAMEWORKS'
          end
        end

        if(state != old_state)
          cluster.update_attribute(:state, state)
          cluster.update(user_id, cluster[:uuid], state)
        end
      end
    end
  end
end
