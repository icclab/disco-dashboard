class ClusterUpdateJob < ApplicationJob
  queue_as :default

  def perform(current_user, id)
    puts "====================================================================="
    puts "                      Cluster id is #{id}"
    puts "====================================================================="
    cluster  = Cluster.find_by(id: id)
    state    = cluster[:state]
    uuid     = cluster[:uuid]

    begin
      sleep(2)
      send_request(current_user, uuid)
      response = send_request(current_user, uuid, 'json')

      res = JSON.parse(response.body)
      state = res["attributes"]["stack_status"]
      if(response.code == "200" && state != cluster[:state])
        cluster.update_attribute(:state, state)
        cluster.update(current_user[:id], uuid, state)

        puts "====================================================================="
        puts "                  State of cluster#{id} was updated"
        puts "====================================================================="
      end
    end until state.downcase.include? 'complete'
  end

  private
    def send_request(current_user, uuid = '', type = 'text')
      url = 'http://160.85.4.252:8888/haas/'+uuid
      uri     = URI.parse(url)
      request = Net::HTTP::Get.new(uri)
      request["X-User-Name"]   = current_user[:username]
      request["X-Password"]    = current_user[:disco_ip]
      request["X-Tenant-Name"] = current_user[:tenant]
      request["Accept"]        = type == "json" ? "application/occi+json" : "text/occi"
      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
        http.request(request)
      end
      return response
    end

    def openstack(current_user)
      stack = OpenStack::Connection.create ({
        username:   current_user[:username],
        api_key:    current_user[:disco_ip],
        auth_url:   current_user[:auth_url],
        authtenant: current_user[:tenant]
      })
      return stack
    end
end
