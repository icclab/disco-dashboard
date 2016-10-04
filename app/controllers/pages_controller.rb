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

  end

  def login
  end

  def debug
    @server = @@openstack.list_servers_detail.first
    @images  = @@openstack.list_images
    @flavors = @@openstack.list_flavors
  end

  def create
    puts JSON.pretty_generate(params[:cluster])
    respond_to do |format|
      format.js
    end
  end

  def details
    @src = params[:src]
    if @src == 'disco'
      instance   = params[:server]
      @id        = instance["kind"]["title"]
      attributes = instance["attributes"]
      @master_n  = attributes["icclab.haas.master.number"]
      @slave_n   = attributes["icclab.haas.slave.number"]
      @info      = attributes["externalIP"]
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

  def get_image(stack, is_os)
    if is_os
      id = stack[:image][:id]
      return @@openstack.get_image(id)
    else
      id_m = stack["attributes"]["icclab.haas.master.image"]
      id_s = stack["attributes"]["icclab.haas.slave.image"]
      return @@openstack.get_image(id_m), @@openstack.get_image(id_s)
    end
  end

  def get_flavor(stack, is_os)
    if is_os
      id = stack[:flavor][:id]
      return @@openstack.get_flavor(id)
    else
      id_m = stack["attributes"]["icclab.haas.master.flavor"]
      id_s = stack["attributes"]["icclab.haas.slave.flavor"]
      return @@openstack.get_flavor(id_m), @@openstack.get_flavor(id_s)
    end
  end

  # Authenticate to DISCO
  def list_disco(username, password, tenant, disco_uri)
    uri     = URI.parse(disco_uri)
    request = Net::HTTP::Get.new(uri)

    request["Accept"]        = "application/occi+json"
    request["X-User-Name"]   = username
    request["X-Password"]    = password
    request["X-Tenant-Name"] = tenant

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
      http.request(request)
    end

    puts response.code

    if response.code == "200"
      return JSON.parse(response.body)
    else

      return nil
    end
  end
end
