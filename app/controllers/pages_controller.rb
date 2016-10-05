class PagesController < ApplicationController

  helper_method :get_image, :get_flavor

  def dashboard
    @servers = @@openstack.list_servers_detail
    @images  = @@openstack.list_images
    @flavors = @@openstack.list_flavors
    @disco     = list_disco(
        'disco',
        '89,@924;9299[>6',
        'disco',
        'http://160.85.4.252:8888/haas/'
    )
    @disco.each { |e| @disco.delete(e) if !e["attributes"]["icclab.haas.master.image"] }
  end

  def login
  end

  # Method for debugging
  def debug
    @server = @@openstack.list_servers_detail.first
    @images  = @@openstack.list_images
    @flavors = @@openstack.list_flavors
  end

  # DISCO

  # Authenticate and get instances from DISCO
  def list_disco(username, password, tenant, disco_uri)
    uri     = URI.parse(disco_uri)
    request = Net::HTTP::Get.new(uri)

    request["Accept"]        = "text/occi"
    request["X-User-Name"]   = username
    request["X-Password"]    = password
    request["X-Tenant-Name"] = tenant

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
      http.request(request)
    end

    request["Accept"]        = "application/occi+json"

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
      http.request(request)
    end

    if response.code == "200"
      return JSON.parse(response.body)
    else
      return nil
    end
  end

  # Method to create a cluster on DISCO
  def create
    cluster = params[:cluster]
    uri = URI.parse("http://160.85.4.252:8888/haas/")
    request = Net::HTTP::Post.new(uri)
    request.content_type        = "text/occi"
    request["Category"]         = 'haas; scheme="http://schemas.cloudcomplab.ch/occi/sm#"; class="kind";'
    request["X-Tenant-Name"]    = 'disco'
    request["X-Region-Name"]    = 'RegionOne'
    request["X-User-Name"]      = 'disco'
    request["X-Password"]       = '89,@924;9299[>6'
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

  def delete
    uuid = params[:uuid]
    uri  = URI.parse("http://160.85.4.252:8888/haas/#{uuid}")
    request = Net::HTTP::Delete.new(uri)
    request.content_type     = "text/occi"
    request["Category"]      = 'haas; scheme="http://schemas.cloudcomplab.ch/occi/sm#"; class="kind";'
    request["X-Tenant-Name"] = 'disco'
    request["X-Region-Name"] = 'RegionOne'
    request["X-User-Name"]   = 'disco'
    request["X-Password"]    = '89,@924;9299[>6'

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
      http.request(request)
    end

    if response.code != 200
      raise
    end
  end

  # Method to get all details of the chosen cluster
  def details
    @src = params[:src]
    if @src == 'disco'
      instance   = params[:server]
      @title     = instance["kind"]["title"]
      attributes = instance["attributes"]
      @master_n  = attributes["icclab.haas.master.number"]
      @slave_n   = attributes["icclab.haas.slave.number"]
      @info      = attributes["externalIP"]+" <p></p> "+attributes["statusText"]
      @id        = attributes["occi.core.id"]
      @id.slice! '/haas/'
      @uuid      = "delete?uuid="+@id
    else
      server   = params[:server]
      @id      = server[:hostId]
      @image   = server[:image][:id]
      @flavor  = server[:flavor][:id]
      @info    = server[:addresses][:public].first[:addr]
    end
    respond_to do |format|
      format.js
    end
  end

  # Helper methods to get image and flavor names
    def get_image(stack, is_os)
      if is_os
        id = stack[:image][:id]
        return @@openstack.get_image(id)
      else
        id_m = stack["attributes"]["icclab.haas.master.image"]
        id_s = stack["attributes"]["icclab.haas.slave.image"]
        return @@openstack.get_image(id_m), @@openstack.get_image(id_s) if id_s && id_m
      end
    end

    def get_flavor(stack, is_os)
      if is_os
        id = stack[:flavor][:id]
        return @@openstack.get_flavor(id)
      else
        id_m = stack["attributes"]["icclab.haas.master.flavor"]
        id_s = stack["attributes"]["icclab.haas.slave.flavor"]
        return @@openstack.get_flavor(id_m), @@openstack.get_flavor(id_s) if id_s && id_m
      end
    end
end
