class ClusterUpdateJob < ApplicationJob
  queue_as :default

  def perform(infrastructure, user_id, cluster_id, password)
    puts "====================================================================="
    puts "                      Cluster id is #{cluster_id}"
    puts user_id, cluster_id, password
    puts "====================================================================="
    cluster  = Cluster.find(cluster_id)
    state    = cluster[:state]
    uuid     = cluster[:uuid]

    begin
      sleep(2)
      send_request(infrastructure, password, uuid)
      response = send_request(infrastructure, password, uuid, 'json')

      res = JSON.parse(response.body)
      state = res["attributes"]["stack_status"]
      if(response.code == "200" && state != cluster[:state])
        cluster.update_attribute(:state, state)
        cluster.update(user_id, uuid, state)
      end
    end until state.downcase.include?('completed') || state.downcase.include?('failed')
  end

  private
    def send_request(infrastructure, password, uuid = '', type = 'text')
      url = ENV["disco_ip"]+uuid
      uri     = URI.parse(url)
      request = Net::HTTP::Get.new(uri)
      request["X-User-Name"]   = infrastructure[:username]
      request["X-Password"]    = password
      request["X-Tenant-Name"] = infrastructure[:tenant]
      request["Accept"]        = type == "json" ? "application/occi+json" : "text/occi"
      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
        http.request(request)
      end
      return response
    end
end
