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

    clusters.each do |cluster|
      uri     = URI.parse(cluster)
      request = Net::HTTP::Get.new(uri)
      request["X-User-Name"]   = current_user[:username]
      request["X-Password"]    = current_user[:disco_ip]
      request["X-Tenant-Name"] = current_user[:tenant]
      request["Accept"]        = "text/occi"
      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
        http.request(request)
      end
    end

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
