# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class ClusterChannel < ApplicationCable::Channel

  periodically :update_clusters, every: 30

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

  def update_clusters

    current_user = User.find(user_id)
    clusters = current_user.clusters.all
    clusters.each do |cluster|
      ip = IPAddr.new(cluster[:external_ip], Socket::AF_INET).to_s
      url = "http://"+ip+":8084/progress.log"
      uri     = URI.parse(url)
      request = Net::HTTP::Get.new(uri)
      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
        http.request(request)
      end

      state = old_state = cluster[:state]
      if response.code == "200"
        if response.body.to_i == 1
          state = 'READY'
        end
      else
        state = 'CONNECTION_FAILED'
      end

      puts "==========================================="
      puts "   cluster_id    => #{cluster[:id]}"
      puts "   state         => #{state}"
      puts "   response.body => #{response.body.to_i}"
      puts "==========================================="
      if(state!=old_state)
        cluster.update_attribute(:state, state)
        cluster.update(user_id, cluster[:uuid], state)
      end
    end
  end
end
