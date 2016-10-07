class PagesController < ApplicationController
  before_action :logged_in_user
  before_action :authenticate_to_openstack

  helper_method :get_image, :get_flavor

  def dashboard
    @images  = @@openstack.list_images
    @flavors = @@openstack.list_flavors
    @disco   = list_disco
  end

  # DISCO

  # Authenticate and get instances from DISCO
  def list_disco
    uri     = URI.parse(@@disco_ip)
    request = Net::HTTP::Get.new(uri)

    request["Accept"]        = "text/occi"
    request["X-User-Name"]   = current_user[:username]
    request["X-Password"]    = current_user[:disco_ip]
    request["X-Tenant-Name"] = current_user[:tenant]

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
      http.request(request)
    end

    clusters = ''
    response.header.each_header {|key,value| clusters = value.split(', ') if key=='x-occi-location' }

    list = []
    clusters.each do |cluster|
      uri     = URI.parse(cluster)
      request = Net::HTTP::Get.new(uri)
      request["X-User-Name"]   = current_user[:username]
      request["X-Password"]    = current_user[:disco_ip]
      request["X-Tenant-Name"] = current_user[:tenant]
      request["Accept"]        = "application/occi+json"
      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
        http.request(request)
      end

      if response.code == "200"
        list << JSON.parse(response.body)
      end

    end

    return list
  end

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

  def delete
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
  def details
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

  # Helper methods to get image and flavor names
    def get_image(stack)
      id_m = stack["attributes"]["icclab.haas.master.image"]
      id_s = stack["attributes"]["icclab.haas.slave.image"]
      return @@openstack.get_image(id_m), @@openstack.get_image(id_s) if id_s && id_m
    end

    def get_flavor(stack)
      id_m = stack["attributes"]["icclab.haas.master.flavor"]
      id_s = stack["attributes"]["icclab.haas.slave.flavor"]
      return @@openstack.get_flavor(id_m), @@openstack.get_flavor(id_s) if id_s && id_m
    end

  private
    def logged_in_user
      unless logged_in?
        redirect_to login_url
      end
    end

    def authenticate_to_openstack
      @current_user = current_user
      puts "------------------------------------------"
      puts @current_user[:username]
      puts @current_user[:tenant]
      puts @current_user[:auth_url]
      puts @current_user[:disco_ip]
      puts "------------------------------------------"
      @@openstack = OpenStack::Connection.create ({
        username:   current_user[:username],
        api_key:    current_user[:disco_ip],
        auth_url:   current_user[:auth_url],
        authtenant: current_user[:tenant]
      })
    end
end
