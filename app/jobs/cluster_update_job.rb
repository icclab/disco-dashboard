#
# Copyright (c) 2015. Zuercher Hochschule fuer Angewandte Wissenschaften
#  All Rights Reserved.
#
#     Licensed under the Apache License, Version 2.0 (the "License"); you may
#     not use this file except in compliance with the License. You may obtain
#     a copy of the License at
#
#          http://www.apache.org/licenses/LICENSE-2.0
#
#     Unless required by applicable law or agreed to in writing, software
#     distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#     WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#     License for the specific language governing permissions and limitations
#     under the License.
#

#
#     Author: Saken Kenzhegulov,
#     URL: https://github.com/skenzhegulov
#

class ClusterUpdateJob < ApplicationJob
  include DiscoHelper

  queue_as :default

  def perform(infrastructure, user_id, cluster_id, password)
    # all this method is prone to exceptions - see rescue branch!
    begin
      cluster  = Cluster.find(cluster_id)
      state    = cluster[:state]
      uuid     = cluster[:uuid]

      puts(cluster)

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
            ip = convert_ip(res["attributes"]["external_ip"])
            cluster.update_attribute(:external_ip, ip)
            spk = res["attributes"]["ssh_private_key"]
            cluster.update_attribute(:ssh_private_key, spk)
          end
        end
      end until state.downcase.include?('complete') || state.downcase.include?('fail')

      cluster.update(user_id, uuid, 'INSTALLING_FRAMEWORKS') if state.downcase.include? 'complete'
    rescue Exception => e
      # nothing can be done here; cluster might have been removed before its state was complete
      # (flash is impossible as no request is being handled and cluster.update is impossible as
      # cluster with requested ID might not exist -> let's just pretend no exception happened)
    end
  end

  private
    # Method to convert string ip address to int
    def convert_ip(addr)
      addr!=nil && addr!="none" ? IPAddr.new(addr).to_i : nil
    end
end
