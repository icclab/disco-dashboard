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
    response = send_request

    clusters = ''
    response.header.each_header {|key,value| clusters = value.split(', ') if key=='x-occi-location' }

    clusters.each { |cluster| send_request(cluster) }

    list = []
    clusters.each do |cluster|
      response = send_request(cluster, "json")
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
end
