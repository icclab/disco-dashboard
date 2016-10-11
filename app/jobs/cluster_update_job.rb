class ClusterUpdateJob < ApplicationJob
  queue_as :default
  include ApplicationController

  def perform(id)
    cluster = Cluster.find_by(id: id)
    state = cluster[:state]

    #uri     = URI.parse(@@disco_ip)
    #request = Net::HTTP::Get.new(uri)

    #request["Accept"]        = "text/occi"
    #request["X-User-Name"]   = current_user[:username]
    #request["X-Password"]    = current_user[:disco_ip]
    #request["X-Tenant-Name"] = current_user[:tenant]

    response = send_request
    #= Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
    #  http.request(request)
    #end

    clusters = ''
    response.header.each_header {|key,value| clusters = value.split(', ') if key=='x-occi-location' }

    begin
      sleep(5)
      send_request(cluster)
      #uri     = URI.parse(clusters.first)
      #request = Net::HTTP::Get.new(uri)
      #request["X-User-Name"]   = current_user[:username]
      #request["X-Password"]    = current_user[:disco_ip]
      #request["X-Tenant-Name"] = current_user[:tenant]
      #request["Accept"]        = "text/occi"
      #response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
      #  http.request(request)
      #end

      #request = Net::HTTP::Get.new(uri)
      #request["X-User-Name"]   = current_user[:username]
      #request["X-Password"]    = current_user[:disco_ip]
      #request["X-Tenant-Name"] = current_user[:tenant]
      #request["Accept"]        = "application/occi+json"
      #response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
      #  http.request(request)
      #end

      response = send_request(cluster, 'json')

      res = JSON.parse(response.body)
      state = res["attributes"]["stack_status"]
      if(response.code ==200 && state != cluster[:state])
        cluster.update_attribute(:state, state)
      end
    end until state.downcase.include? 'complete'
  end
end
