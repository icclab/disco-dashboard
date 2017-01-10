class ClusterUpdateJob < ApplicationJob
  include DiscoHelper

  queue_as :default

  def perform(infrastructure, user_id, cluster_id, password)
    cluster  = Cluster.find(cluster_id)
    state    = cluster[:state]
    uuid     = cluster[:uuid]

    begin
      sleep(3)

      send_request(infrastructure, password, uuid)
      response = send_request(infrastructure, password, uuid, 'json')

      if(response.code == "200")
        if(response.body)
          res = JSON.parse(response.body)
          state = res["attributes"]["stack_status"] if res["attributes"]["stack_status"]
        end

        cluster.update(user_id, uuid, state) if state != cluster[:state]

        if state.downcase.include?('complete')
          ip = convert_ip(res["attributes"]["externalIP"])
          cluster.update_attribute(:external_ip, ip)
        end
      end
    end until state.downcase.include?('complete') || state.downcase.include?('fail')

    cluster.update(user_id, uuid, 'INSTALLING_FRAMEWORKS') if state.downcase.include? 'complete'
  end

  private
    # Method to convert string ip address to int
    def convert_ip(addr)
      addr!=nil && addr!="none" ? IPAddr.new(addr).to_i : nil
    end
end
