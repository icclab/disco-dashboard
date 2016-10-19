class ClustersController < ApplicationController
  before_action :logged_in_user

  include PagesHelper

  # Method to create a cluster on DISCO
  def create
    cluster = params[:cluster]
    new_cluster = current_user.clusters.build(cluster_params)
    if new_cluster.save
      uri = URI.parse(@@disco_ip)
      request = Net::HTTP::Post.new(uri)
      request.content_type        = "text/occi"
      request["Category"]         = 'haas; scheme="http://schemas.cloudcomplab.ch/occi/sm#"; class="kind";'
      request["X-Tenant-Name"]    = current_user[:tenant]
      request["X-Region-Name"]    = 'RegionOne'
      request["X-User-Name"]      = current_user[:username]
      request["X-Password"]       = current_user[:disco_ip]
      request["X-Occi-Attribute"] = 'icclab.haas.master.image="'+cluster[:master_image]+'",icclab.haas.slave.image="'+cluster[:slave_image]+'",icclab.haas.master.sshkeyname="discokey",icclab.haas.master.flavor="'+cluster[:master_flavor]+'",icclab.haas.slave.flavor="'+cluster[:slave_flavor]+'",icclab.haas.master.number="'+cluster[:master_num]+'",icclab.haas.slave.number="'+cluster[:slave_num]+'",icclab.haas.master.slaveonmaster="'+(cluster[:master_slave] ? "true" : "false")+'",icclab.haas.master.withfloatingip="true",icclab.disco.frameworks.spark.included="True",icclab.disco.frameworks.hadoop.included="True",icclab.disco.frameworks.zeppelin.included="True",icclab.disco.frameworks.jupyter.included="True"'

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
        http.request(request)
      end

      if response.code == "201"
        uuid = nil
        response.header.each_header { |key, value| uuid = value.split(//).last(36).join if key =="location" }
        new_cluster.update_attribute(:uuid, uuid)
        ActionCable.server.broadcast "cluster_#{current_user[:id]}",
                                     type: 1,
                                     cluster: render_cluster(new_cluster)
        #run background job
        puts "====================================================================="
        puts "         Running background job on cluster #{new_cluster[:id]}"
        puts "====================================================================="
        ClusterUpdateJob.perform_later(current_user, new_cluster[:id])
        sleep(3)
      else
        new_cluster.delete
        puts "New cluster deleted from database due to failure on creation"
      end
    else
      puts "Failed to save"
    end
  end

  # Method to delete chosen cluste
  def destroy
    uuid = params[:uuid]
    uri  = URI.parse(@@disco_ip+uuid)
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

    if response.code != "200"
      raise
    else
      flash[:success] = "Cluster delete in progress"
    end

    redirect_to :back
  end

  # Method to get all details of the chosen cluster
  def show
    uuid   = params[:uuid]
    cluster = current_user.clusters.find_by(uuid: uuid)
    @title    = cluster[:name]
    @master_n = cluster[:master_num]
    @slave_n  = cluster[:slave_num]
    @info     = IPAddr.new(cluster[:external_ip], Socket::AF_INET).to_s
    @id       = uuid
    @link     = "delete?uuid="+@id

    respond_to do |format|
      format.js
    end
  end

  private
    def cluster_params
      params.require(:cluster).permit(:name, :uuid, :state,
                                      :master_name, :slave_name,
                                      :master_image, :slave_image,
                                      :master_flavor, :slave_flavor,
                                      :master_name, :slave_num,
                                      :master_slave)
    end

    def render_cluster(cluster)
      m_image = @@openstack.get_image(cluster[:master_image])
      s_image = @@openstack.get_image(cluster[:slave_image])
      m_flavor = @@openstack.get_flavor(cluster[:master_flavor])
      s_flavor = @@openstack.get_flavor(cluster[:slave_flavor])
      render(partial: 'cluster', locals: { cluster: cluster,
                                           m_image: m_image,
                                           s_image: s_image,
                                           m_flavor: m_flavor,
                                           s_flavor: s_flavor })
    end
end