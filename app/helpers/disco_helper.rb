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

    require 'uri'
    require 'net/http'
    require 'net/https'

    @toSend = JSON.generate({ "auth" =>  { "passwordCredentials" => { "username" => infrastructure[:username], "password" => cluster[:password] }, "tenantName" => infrastructure[:tenant]}})

    begin
      res = RestClient::Request.execute(method: :post, payload: @toSend, url: infrastructure[:auth_url]+"/tokens", headers:{:'Content-Type'=>'application/json'}, read_timeout: ENV['read_timeout'].to_i, open_timeout: ENV['open_timeout'].to_i)
      obj = JSON.parse(res.body)
      token = obj['access']['token']['id']
    rescue
      flash[:danger] = "Error fetching Token from Openstack - wrong password given?"
      return ""
    end

    request.content_type         = "text/occi"
    request["Category"]          = 'disco; scheme="http://schemas.cloudcomplab.ch/occi/sm#"; class="kind";'
    request["X-Tenant-Name"]     = infrastructure[:tenant]
    request["X-Region-Name"]     = infrastructure[:region]
    request["X-User-Name"]       = infrastructure[:username]
    request["X-Password"]        = cluster[:password]
    request["X-Auth-Token"]      = token

    headers = {}
    headers['Category'] = 'disco; scheme="http://schemas.cloudcomplab.ch/occi/sm#"; class="kind";'
    headers['X-Tenant-Name'] = infrastructure[:tenant]
    headers['X-Region-Name'] = infrastructure[:region]
    headers['X-User-Name'] = infrastructure[:username]
    headers['X-Password'] = cluster[:password]
    headers['X-Auth-Token'] = token

    master_image = Image.find(cluster[:master_image])
    request["X-Occi-Attribute"]  = 'icclab.disco.components.heat.masterimage="'+master_image.img_id+'",'
    slave_image = Image.find(cluster[:slave_image])
    request["X-Occi-Attribute"] += 'icclab.disco.components.heat.slaveimage="'+slave_image.img_id+'",'

    master_flavor = Flavor.find(cluster[:master_flavor])
    request["X-Occi-Attribute"] += 'icclab.disco.components.heat.masterflavor="'+master_flavor.fl_id+'",'
    slave_flavor = Flavor.find(cluster[:slave_flavor])
    request["X-Occi-Attribute"] += 'icclab.disco.components.heat.slaveflavor="'+slave_flavor.fl_id+'",'

    request["X-Occi-Attribute"] += 'icclab.disco.components.heat.slavecount="'+cluster[:slave_num].to_s+'",'

    request["X-Occi-Attribute"] += 'icclab.disco.deployer.username="'+infrastructure[:username]+'",'
    request["X-Occi-Attribute"] += 'icclab.disco.deployer.region="'+infrastructure[:region]+'",'
    request["X-Occi-Attribute"] += 'icclab.disco.deployer.password="'+cluster[:password]+'",'


    # from here on, there are only a few dummy data sets:
    randomstring = (0...8).map { (65 + rand(26)).chr }.join
    request["X-Occi-Attribute"] += 'icclab.disco.components.heat.networkname="disconetwork-'+randomstring+'",'
    request["X-Occi-Attribute"] += 'icclab.disco.components.heat.externalnetworkname="'+ENV['external_network']+'",'
    # until here

    # check if Jupyter is to be installed - if so, add password to its access
    begin
      if params[:cluster][:Jupyter]=="1"
        request["X-Occi-Attribute"] += 'icclab.disco.components.jupyter.password="'+params[:cluster][:jupyterpwd]+'",'
      end
    rescue
    end



    request["X-Occi-Attribute"] += 'icclab.disco.dependencies.inject="{\''
    current_length = request["X-Occi-Attribute"].length
    frameworks = Framework.all
    frameworks.each do |framework|
      # puts(value(cluster[framework[:name]]))
      if value(cluster[framework[:name]]) == 'true'
        request["X-Occi-Attribute"] += framework[:name].downcase+"': '','"
      end
    end

    # remove the last comma from "framework1,framework2," if
    if request["X-Occi-Attribute"].length!=current_length
      # if there were frameworks added, there is a `,'` too much at the end
      request["X-Occi-Attribute"] = request["X-Occi-Attribute"].chomp(",\'")
    else
      # if there was no framework added, there is still a `'` too much at the and
      request["X-Occi-Attribute"] = request["X-Occi-Attribute"].chomp("\'")
    end

    request["X-Occi-Attribute"] += '}"'


    headers['X-Occi-Attribute'] = request['X-Occi-Attribute']

    Rails.logger.debug {"Cluster attributes: #{request["X-Occi-Attribute"].inspect}"}

    response = 0
    begin
      res = RestClient::Request.execute(:method => :post, :url => ENV['disco_ip'], headers:{"X-Auth-Token" => token,"X-Tenant-Name" => infrastructure[:tenant],"X-User-Name"=>infrastructure[:username],"X-Region-Name"=>infrastructure[:region],"X-Password"=>cluster[:password],"X-Occi-Attribute"=>headers['X-Occi-Attribute'],:"Category"=>request["Category"],:accept=>"*/*",:"Content-Type"=>"text/occi"})
    rescue Exception => e
      res = e
    end

    return res
  end

  def runstate_req(infrastructure, password, uuid, runstate)
    uri     = URI.parse(ENV["disco_ip"]+uuid)
    request = Net::HTTP::Post.new(uri)

    require 'uri'
    require 'net/http'
    require 'net/https'

    @toSend = JSON.generate({ "auth" =>  { "passwordCredentials" => { "username" => infrastructure[:username], "password" => password }, "tenantName" => infrastructure[:tenant]}})

    keystone = infrastructure[:auth_url] # 'https://keystone.cloud.switch.ch:5000/v2.0'
    keystoneuri = URI.parse(keystone+'/tokens')
    https = Net::HTTP.new(keystoneuri.host,keystoneuri.port)
    https.use_ssl = keystoneuri.instance_of? URI::HTTPS
    https.open_timeout = ENV['open_timeout'].to_i
    https.read_timeout = ENV['read_timeout'].to_i
    req = Net::HTTP::Post.new(keystoneuri.path, initheader = {'Content-Type' =>'application/json'})
    req.body = @toSend
    res = https.request(req)

    obj = JSON.parse(res.body)
    token = obj['access']['token']['id']

    request.content_type         = "text/occi"
    request["Category"]          = 'disco; scheme="http://schemas.cloudcomplab.ch/occi/sm#"; class="kind";'
    request["X-Tenant-Name"]     = infrastructure[:tenant]
    request["X-Region-Name"]     = infrastructure[:region]
    request["X-User-Name"]       = infrastructure[:username]
    request["X-Password"]        = password
    request["X-Auth-Token"]      = token

    request["X-Occi-Attribute"]  = 'action="'+runstate+'",'


    Rails.logger.debug {"Cluster attributes: #{request["X-Occi-Attribute"].inspect}"}

    response = Net::HTTP.start(uri.hostname, uri.port, :read_timeout => ENV['read_timeout'].to_i, :open_timeout => ENV['open_timeout'].to_i) do |http|
      http.request(request)
    end

    response
  end

  # Method accepts infrastructure credentials and cluster uuid
  # to send delete request to DISCO to delete chosen cluster from the stacks.
  # Returns response from DISCO framework.
  def delete_req(infrastructure, password, uuid)
    require 'uri'
    require 'net/http'
    require 'net/https'

    @toSend = JSON.generate({ "auth" =>  { "passwordCredentials" => { "username" => infrastructure[:username], "password" => password }, "tenantName" => infrastructure[:tenant]}})

    keystone = infrastructure[:auth_url] # 'https://keystone.cloud.switch.ch:5000/v2.0'
    keystoneuri = URI.parse(keystone+'/tokens')
    https = Net::HTTP.new(keystoneuri.host,keystoneuri.port)
    https.use_ssl = keystoneuri.instance_of? URI::HTTPS
    https.open_timeout = ENV['open_timeout'].to_i
    https.read_timeout = ENV['read_timeout'].to_i
    req = Net::HTTP::Post.new(keystoneuri.path, initheader = {'Content-Type' =>'application/json'})
    req.body = @toSend
    res = https.request(req)

    obj = JSON.parse(res.body)
    token = obj['access']['token']['id']



    uri  = URI.parse(ENV["disco_ip"]+uuid)

    request = Net::HTTP::Delete.new(uri)
    request.content_type     = "text/occi"
    request["Category"]      = 'disco; scheme="http://schemas.cloudcomplab.ch/occi/sm#"; class="kind";'
    request["X-Tenant-Name"] = infrastructure[:tenant]
    request["X-Region-Name"] = infrastructure[:region]
    request["X-User-Name"]   = infrastructure[:username]
    request["X-Password"]    = password
    request["X-Auth-Token"]  = token

    begin
      response = Net::HTTP.start(uri.hostname, uri.port, :read_timeout => ENV['read_timeout'].to_i, :open_timeout => ENV['open_timeout'].to_i) do |http|
        http.request(request)
    end
    rescue => ex
      logger.error ex.message
      # devilish code: DISCO is not online
      # a new class had to be created with property code
      response = Object.new
      response.class.module_eval { attr_accessor :code}
      response.code = "666"
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
    require 'uri'
    require 'net/http'
    require 'net/https'

    @toSend = JSON.generate({ "auth" =>  { "passwordCredentials" => { "username" => infrastructure[:username], "password" => password }, "tenantName" => infrastructure[:tenant]}})

    keystone = infrastructure[:auth_url]
    keystoneuri = URI.parse(keystone+'/tokens')
    https = Net::HTTP.new(keystoneuri.host,keystoneuri.port)
    https.use_ssl = keystoneuri.instance_of? URI::HTTPS
    https.open_timeout = ENV['open_timeout'].to_i
    https.read_timeout = ENV['read_timeout'].to_i
    req = Net::HTTP::Post.new(keystoneuri.path, initheader = {'Content-Type' =>'application/json'})
    req.body = @toSend
    res = https.request(req)

    obj = JSON.parse(res.body)
    token = obj['access']['token']['id']

    uri  = URI.parse(ENV["disco_ip"]+uuid)
    request = Net::HTTP::Get.new(uri)
    request["X-User-Name"]   = infrastructure[:username]
    request["X-Password"]    = password
    request["X-Tenant-Name"] = infrastructure[:tenant]
    request["X-Region-Name"] = infrastructure[:region]
    request["X-Auth-Token"]  = token
    request["Accept"]        = type == "json" ? "application/occi+json" : "text/occi"
    response = Net::HTTP.start(uri.hostname, uri.port, :read_timeout => ENV['read_timeout'].to_i, :open_timeout => ENV['open_timeout'].to_i) do |http|
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
