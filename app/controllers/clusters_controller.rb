class ClustersController < ApplicationController
  before_action :logged_in_user

  # Method to create a cluster on DISCO
  def create
    infrastructure = Infrastructure.find(params[:cluster][:infrastructure_id])
    cluster = infrastructure.clusters.build(cluster_params)
    if cluster.save
      uri     = URI.parse(ENV["disco_ip"])
      request = Net::HTTP::Post.new(uri)
      request.content_type         = "text/occi"
      request["Category"]          = 'haas; scheme="http://schemas.cloudcomplab.ch/occi/sm#"; class="kind";'
      request["X-Tenant-Name"]     = infrastructure[:tenant]
      request["X-Region-Name"]     = 'RegionOne'
      request["X-User-Name"]       = infrastructure[:username]
      request["X-Password"]        = params[:cluster][:password]
      request["X-Occi-Attribute"]  = 'icclab.haas.master.image="'+cluster.master_image+'",'
      request["X-Occi-Attribute"] += 'icclab.haas.slave.image="'+cluster.slave_image+'",'
      request["X-Occi-Attribute"] += 'icclab.haas.master.sshkeyname="discokey",'
      request["X-Occi-Attribute"] += 'icclab.haas.master.flavor="'+cluster.master_flavor+'",'
      request["X-Occi-Attribute"] += 'icclab.haas.slave.flavor="'+cluster.slave_flavor+'",'
      request["X-Occi-Attribute"] += 'icclab.haas.master.number="'+cluster.master_num.to_s+'",'
      request["X-Occi-Attribute"] += 'icclab.haas.slave.number="'+cluster.slave_num.to_s+'",'
      value = Proc.new { |a| a ? "true" : "false" }
      request["X-Occi-Attribute"] += 'icclab.haas.master.slaveonmaster="'+value(cluster.slave_on_master)+'",'
      request["X-Occi-Attribute"] += 'icclab.haas.master.withfloatingip="true",'
      request["X-Occi-Attribute"] += 'icclab.disco.frameworks.spark.included="'+value(cluster.spark)+'",'
      request["X-Occi-Attribute"] += 'icclab.disco.frameworks.hadoop.included="'+value(cluster.hadoop)+'",'
      request["X-Occi-Attribute"] += 'icclab.disco.frameworks.zeppelin.included="'+value(cluster.zeppelin)+'",'
      request["X-Occi-Attribute"] += 'icclab.disco.frameworks.jupyter.included="'+value(cluster.jupyter)+'"'

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
        http.request(request)
      end

      if response.code == "201"
        uuid = nil
        response.header.each_header { |key, value| uuid = value.split(//).last(36).join if key =="location" }
        cluster.update_attribute(:uuid, uuid)
        ActionCable.server.broadcast "cluster_#{current_user[:id]}",
                                     type: 1,
                                     cluster: render_cluster(cluster)
        #run background job
        puts "====================================================================="
        puts "         Running background job on cluster #{cluster.id}"
        puts "====================================================================="
        ClusterUpdateJob.perform_later(infrastructure, current_user[:id], cluster[:id], params[:cluster][:password])
        sleep(3)
      else
        cluster.delete
        puts "New cluster deleted from database due to failure on creation"
      end
    else
      puts "Failed to save"
    end
  end

  # Method to delete chosen cluster
  def destroy
    uuid = params[:delete][:uuid]
    cluster = Cluster.find_by(uuid: uuid)
    infrastructure = Infrastructure.find(cluster.infrastructure_id)
    uri  = URI.parse(ENV["disco_ip"]+uuid)
    request = Net::HTTP::Delete.new(uri)
    request.content_type     = "text/occi"
    request["Category"]      = 'haas; scheme="http://schemas.cloudcomplab.ch/occi/sm#"; class="kind";'
    request["X-Tenant-Name"] = infrastructure[:tenant]
    request["X-Region-Name"] = 'RegionOne'
    request["X-User-Name"]   = infrastructure[:username]
    request["X-Password"]    = params[:delete][:password]

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
      http.request(request)
    end

    if response.code != "200"
      puts "================================="
      puts "      Something went wrong"
      puts "================================="
    else
      puts "================================="
      puts "    Cluster delete in progress"
      puts "================================="
      cluster.delete
    end

    redirect_to :back
  end

  # Method to get all details of the chosen cluster
  def show
    uuid      = params[:uuid]
    cluster   = Cluster.find_by(uuid: uuid)
    @title    = cluster[:name]
    @master_n = cluster[:master_num]
    @slave_n  = cluster[:slave_num]
    @ip       = IPAddr.new(cluster[:external_ip], Socket::AF_INET).to_s
    @id       = uuid
    @infrastructure_id = cluster.infrastructure_id
    @info = cluster.state
  end


  private
    def cluster_params
      params.require(:cluster).permit(:name,  :uuid,  :state,
                                      :master_image,  :slave_image,
                                      :master_flavor, :slave_flavor,
                                      :master_num,    :slave_num,
                                      :slave_on_master)
    end

    def render_cluster(cluster)
      render(partial: 'cluster', locals: { cluster:  cluster })
    end
end
