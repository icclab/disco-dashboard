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

# DiscoHelper contains all methods to connect to the DISCO framework
# through http connection.
module DiscoHelper
  # Method accepts new cluster parameters and infrastructure credentials
  # to send new cluster creation request to DISCO framework.
  # Returns response from the DISCO if any.
  def create_req(cluster, infrastructure)
    uri     = URI.parse(ENV["disco_ip"])
    request = Net::HTTP::Post.new(uri)

    request.content_type         = "text/occi"
    request["Category"]          = 'haas; scheme="http://schemas.cloudcomplab.ch/occi/sm#"; class="kind";'
    request["X-Tenant-Name"]     = infrastructure[:tenant]
    request["X-Region-Name"]     = infrastructure[:region]
    request["X-User-Name"]       = infrastructure[:username]
    request["X-Password"]        = cluster[:password]

    master_image = Image.find(cluster[:master_image])
    request["X-Occi-Attribute"]  = 'icclab.haas.master.image="'+master_image.img_id+'",'
    slave_image = Image.find(cluster[:slave_image])
    request["X-Occi-Attribute"] += 'icclab.haas.slave.image="'+slave_image.img_id+'",'

    request["X-Occi-Attribute"] += 'icclab.haas.master.sshkeyname="'+cluster[:keypair]+'",'

    master_flavor = Flavor.find(cluster[:master_flavor])
    request["X-Occi-Attribute"] += 'icclab.haas.master.flavor="'+master_flavor.fl_id+'",'
    slave_flavor = Flavor.find(cluster[:slave_flavor])
    request["X-Occi-Attribute"] += 'icclab.haas.slave.flavor="'+slave_flavor.fl_id+'",'

    request["X-Occi-Attribute"] += 'icclab.haas.master.number="'+cluster[:master_num].to_s+'",'
    request["X-Occi-Attribute"] += 'icclab.haas.slave.number="'+cluster[:slave_num].to_s+'",'

    request["X-Occi-Attribute"] += 'icclab.haas.master.slaveonmaster="'+value(cluster[:slave_on_master])+'",'

    frameworks = Framework.all
    frameworks.each do |framework|
      if !framework.name.eql? "HDFS"
        request["X-Occi-Attribute"] += 'icclab.disco.frameworks.'+framework[:name].downcase
        request["X-Occi-Attribute"] += '.included="'+value(cluster[framework[:name]])+'",'
      end
    end

    request["X-Occi-Attribute"] += 'icclab.haas.master.withfloatingip="true"'

    Rails.logger.debug {"Cluster attributes: #{request["X-Occi-Attribute"].inspect}"}

    response = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(request)
    end

    response
  end

  # Method accepts infrastructure credentials and cluster uuid
  # to send delete request to DISCO to delete chosen cluster from the stacks.
  # Returns response from DISCO framework.
  def delete_req(infrastructure, password, uuid)
    uri  = URI.parse(ENV["disco_ip"]+uuid)

    request = Net::HTTP::Delete.new(uri)
    request.content_type     = "text/occi"
    request["Category"]      = 'haas; scheme="http://schemas.cloudcomplab.ch/occi/sm#"; class="kind";'
    request["X-Tenant-Name"] = infrastructure[:tenant]
    request["X-Region-Name"] = infrastructure[:region]
    request["X-User-Name"]   = infrastructure[:username]
    request["X-Password"]    = password

    response = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(request)
    end

    response
  end

  # Method accepts infratructure credentials and optional parameters as 'uuid' and 'type'
  # to send http request to DISCO framework.
  # When uuid is not given, returns list of clusters on chosen infrastructure.
  # When uuid is given, returns full details of chosen cluster from infrastructure.
  # When type is 'text', DISCO framework response is in text/occi format.
  # When type is 'json', DISCO framework response is in json format.
  def send_request(infrastructure, password, uuid = '', type = 'text')
    url = ENV["disco_ip"]+uuid
    uri     = URI.parse(url)
    request = Net::HTTP::Get.new(uri)
    request["X-User-Name"]   = infrastructure[:username]
    request["X-Password"]    = password
    request["X-Tenant-Name"] = infrastructure[:tenant]
    request["X-Region-Name"] = infrastructure[:region]
    request["Accept"]        = type == "json" ? "application/occi+json" : "text/occi"
    response = Net::HTTP.start(uri.hostname, uri.port) do |http|
        http.request(request)
    end

    response
  end

  private
    # Method that converts incoming 0 and 1 integer to "true" and "false" string, respectively.
    def value(val)
      val.to_i==1 ? "true" : "false"
    end
end
