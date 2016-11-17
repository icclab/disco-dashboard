class ClusterUpdateJob < ApplicationJob
  queue_as :default

  def perform(infrastructure, user_id, cluster_id, password)
    cluster  = Cluster.find(cluster_id)
    state    = cluster[:state]
    uuid     = cluster[:uuid]

    Rails.logger.debug "Cluster initial state: #{state.inspect}"
    Rails.logger.debug "Cluster uuid: #{uuid.inspect}"

    begin
      sleep(3)

      send_request(infrastructure, password, uuid)
      response = send_request(infrastructure, password, uuid, 'json')

      if(response.code == "200")
        if(response.body)
          res = JSON.parse(response.body)
          state = res["attributes"]["stack_status"] if res["attributes"]["stack_status"]
        end

        if(state != cluster[:state])
          cluster.update_attribute(:state, state)
          cluster.update(user_id, uuid, state)
        end
        if state.downcase.include?('complete')
          ip = convert_ip(res["attributes"]["externalIP"])
          cluster.update_attribute(:external_ip, ip)
        end
      end
    end until state.downcase.include?('complete') || state.downcase.include?('fail')

    if state.downcase.include? 'complete'
      cluster.update(user_id, uuid, 'INSTALLING_FRAMEWORKS')
      cluster.update_attribute(:state, 'INSTALLING_FRAMEWORKS')
    end
  end

  private
    def send_request(infrastructure, password, uuid = '', type = 'text')
      url = ENV["disco_ip"]+uuid
      uri     = URI.parse(url)
      request = Net::HTTP::Get.new(uri)
      request["X-User-Name"]   = infrastructure[:username]
      request["X-Password"]    = password
      request["X-Tenant-Name"] = infrastructure[:tenant]
      request["X-Region-Name"] = ENV["region"]
      request["Accept"]        = type == "json" ? "application/occi+json" : "text/occi"
      response = Net::HTTP.start(uri.hostname, uri.port) do |http|
        http.request(request)
      end

      response
    end

    # Method to convert string ip address to int
    def convert_ip(addr)
      addr!=nil && addr!="none" ? IPAddr.new(addr).to_i : nil
    end
end
