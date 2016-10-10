class ClusterController < ApplicationController
# Method to create a cluster on DISCO
  def create
    cluster = params[:cluster]
    uri = URI.parse(@@disco_ip)
    request = Net::HTTP::Post.new(uri)
    request.content_type        = "text/occi"
    request["Category"]         = 'haas; scheme="http://schemas.cloudcomplab.ch/occi/sm#"; class="kind";'
    request["X-Tenant-Name"]    = current_user[:tenant]
    request["X-Region-Name"]    = 'RegionOne'
    request["X-User-Name"]      = current_user[:username]
    request["X-Password"]       = current_user[:disco_ip]
    request["X-Occi-Attribute"] = 'icclab.haas.master.image="'+cluster[:master_image]+'",icclab.haas.slave.image="'+cluster[:slave_image]+'",icclab.haas.master.sshkeyname="discokey",icclab.haas.master.flavor="'+cluster[:master_flavor]+'",icclab.haas.slave.flavor="'+cluster[:slave_flavor]+'",icclab.haas.master.number="'+cluster[:master_num]+'",icclab.haas.slave.number="'+cluster[:slave_num]+'",icclab.haas.master.slaveonmaster="on",icclab.haas.master.withfloatingip="true",icclab.disco.frameworks.spark.included="True",icclab.disco.frameworks.hadoop.included="True",icclab.disco.frameworks.zeppelin.included="True",icclab.disco.frameworks.jupyter.included="True"'

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
      http.request(request)
    end

    if response != 200
      raise
    end

    redirect_to root_url
  end

  # Method to delete chosen cluster

  def destroy
    uuid = params[:uuid]
    uri  = URI.parse(@@disco_ip+"#{uuid}")
    request = Net::HTTP::Delete.new(uri)
    request.content_type     = "text/occi"
    request["Category"]      = 'haas; scheme="http://schemas.cloudcomplab.ch/occi/sm#"; class="kind";'
    request["X-Tenant-Name"] = current_user[:tenant]
    request["X-Region-Name"] = 'RegionOne'
    request["X-User-Name"]   = current_user[:username]
    request["X-Password"]    = current_user[:disco_ip]

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
      http.request(request)
    end

    if response.code != 200
      raise
    end
  end

  # Method to get all details of the chosen cluster
  def show
    instance   = params[:server]
    @title     = instance["kind"]["title"]
    attributes = instance["attributes"]
    @master_n  = attributes["icclab.haas.master.number"]
    @slave_n   = attributes["icclab.haas.slave.number"]
    @info      = attributes["externalIP"]+" <p></p> "+attributes["statusText"]
    @id        = attributes["occi.core.id"]
    @id.slice! '/haas/'
    @uuid      = "delete?uuid="+@id

    respond_to do |format|
      format.js
    end
  end
end
