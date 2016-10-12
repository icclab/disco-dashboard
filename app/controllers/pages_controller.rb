class PagesController < ApplicationController
  before_action :logged_in_user
  before_action :authenticate_to_openstack
  before_action :update_all

  helper_method :get_image, :get_flavor

  def dashboard
    @images   = @@openstack.list_images
    @flavors  = @@openstack.list_flavors
    @clusters = current_user.clusters.all
  end

  # Helper methods to get image and flavor names
    def get_image(stack)
      id_m = stack[:master_image]
      id_s = stack[:slave_image]
      return @@openstack.get_image(id_m), @@openstack.get_image(id_s) if id_s && id_m
    end

    def get_flavor(stack)
      id_m = stack[:master_flavor]
      id_s = stack[:slave_flavor]
      return @@openstack.get_flavor(id_m), @@openstack.get_flavor(id_s) if id_s && id_m
    end


  private

    # Method to update all clusters of current user
    def update_all
      clusters = current_user.clusters.all

      response = send_request

      clusters.each { |cluster| cluster[:uuid] ? send_request(cluster[:uuid]) : cluster.delete }

      clusters.each do |cluster|
        response = send_request(cluster[:uuid], 'json')

        if response.code == "200"
          disco_cluster = JSON.parse(response.body)

          status = disco_cluster["attributes"]["stack_status"]
          ip     = convert_ip(disco_cluster["attributes"]["externalIP"])

          cluster.update_columns(state: status, external_ip: ip)
        else
          cluster.delete
        end
      end
    end

    # Method to convert string ip address to int
    def convert_ip(addr)
      addr!=nil && addr!="none" ? IPAddr.new(addr).to_i : nil
    end
end
