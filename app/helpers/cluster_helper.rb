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

# ClusterHelper module is used to implement additional methods related to clusters
module ClusterHelper
  # Checks link for being broken or not.
  # Returns "success" if link is working,
  #         "danger"  if link is broken.
  def check_link(url)
    Rails.logger.debug url
    uri = URI.parse(url)
    response = nil
    begin
      # uri.host is 0.0.0.0 as long as no other value has been delivered by DISCO
      if uri.host != "0.0.0.0"
        Net::HTTP.start(uri.host, uri.port) { |http|
          response = http.head(uri.path.size > 0 ? uri.path : "/")
        }
      else
        return "danger"
      end
    rescue StandardError
      return "danger"
    end
    "success"
  end

  # Method to update current user's clusters' state if there is any change.
  # Tries to connect to the clusters using their ip addresses.
  # When timeout occurs, updates state to "CONNECTION FAILED"
  # Otherwise, if state is changed then updates state to the new state
  def update_clusters(user_id = current_user.id)
    current_user ||= User.find(user_id)
    Rails.logger.info "Update cluster is being performed on user #{current_user.id}"
    clusters = current_user.clusters.all
    clusters.each do |cluster|
      if cluster[:external_ip]!=0
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
          Rails.logger.debug "Rescued from 'OpenTimeout'"
        rescue Errno::ECONNREFUSED
          state = 'CONNECTION_FAILED'
          Rails.logger.debug "Rescued from 'CONNECTION REFUSED'"
        rescue Errno::EHOSTDOWN
          state = 'CONNECTION_FAILED'
          Rails.logger.debug "Rescued from 'EHOSTDOWN'"
        end

        if response
          Rails.logger.debug "#{response.code}"
          Rails.logger.debug "#{response.body}"
        end
        if response && response.code == "200"
          if response.body.to_i == 1
            state = 'READY'
          else
            state = 'INSTALLING_FRAMEWORKS'
          end
        end

        cluster.update(user_id, cluster[:uuid], state) if state != old_state

      end
    end
  end

end
