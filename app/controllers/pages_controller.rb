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
      user_clusters = current_user.clusters.all

      response = send_request

      clusters = ''
      response.header.each_header {|key,value| clusters = value.split(', ') if key=='x-occi-location' }

      clusters.each { |cluster| send_request(cluster) }

      clusters.each do |cluster|
        response = send_request(cluster, 'json')

        if response.code == "200"
          disco_cluster = JSON.parse(response.body)
          uuid = disco_cluster["attributes"]["occi.core.id"]
          uuid.slice! '/haas/'
          state = disco_cluster["attributes"]["stack_status"]

          user_cluster = user_clusters.find { |s| s[:uuid] == uuid }
          if user_cluster
            user_cluster.update_attribute(:state, state)
          else
            attributes = disco_cluster["attributes"]
            new_cluster = {
              uuid:          uuid,
              state:         state,
              name:          disco_cluster["kind"]["title"],
              master_name:   "master"+uuid,
              slave_name:    "slave"+uuid,
              master_image:  attributes["icclab.haas.master.image"],
              master_flavor: attributes["icclab.haas.master.flavor"],
              slave_image:   attributes["icclab.haas.slave.image"],
              slave_flavor:  attributes["icclab.haas.slave.flavor"],
              master_slave:  attributes["icclab.haas.master.slaveonmaster"]=="on" ? true : false,
              external_ip:   attributes["externalIP"],
              master_num:    attributes["icclab.haas.master.number"],
              slave_num:     attributes["icclab.haas.slave.number"]
            }
            instance = current_user.clusters.build(new_cluster)
            if instance.save
              puts 'New cluster added from disco'
            else
              raise
            end
          end
        end

      end
    end
end
