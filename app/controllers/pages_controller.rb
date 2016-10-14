class PagesController < ApplicationController
  before_action :logged_in_user
  before_action :authenticate_to_openstack
  before_action :update_all

  def dashboard
    @images   = @@openstack.list_images
    @flavors  = @@openstack.list_flavors
    @get_image = Proc.new { |image| @@openstack.get_image(image) }
    @get_flavor = Proc.new { |flavor| @@openstack.get_flavor(flavor) }
    @clusters = current_user.clusters.all
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
