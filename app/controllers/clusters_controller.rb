class ClustersController < ApplicationController
  # Ensures that only logged in user can access to these methods
  before_action :logged_in_user

  def index
    if current_user.usertype != 2
      @clusters = current_user.clusters.all
    else
      @groups = current_user.groups.all
    end
    @frameworks = Framework.all
  end

  def new
    @infrastructures = current_user.infrastructures.all
    @adapters        = { "Choose" => 0 }
    @infrastructures.each { |inf| @adapters[inf.name] = inf.id } if @infrastructures
  end

  def show
    @cluster = Cluster.find(params[:cluster][:id])
  end

  # Method to create a cluster on DISCO
  def create
    @infrastructures = current_user.infrastructures.all
    @adapters        = { "Choose" => 0 }
    @infrastructures.each { |inf| @adapters[inf.name] = inf.id } if @infrastructures
    frameworks = Framework.all
    infrastructure = Infrastructure.find(params[:cluster][:infrastructure_id])
    cluster = infrastructure.clusters.build(cluster_params)
    cluster[:group_id] = 0

    Rails.logger.debug "#{cluster.inspect}"
    Rails.logger.debug "#{cluster.valid?.inspect}"

    if cluster.save
      # If new cluster is properly configured then we send request to the DISCO
      # to create a new cluster
      response = create_req(params[:cluster], infrastructure, frameworks)
      if response.code == "201"
        Rails.logger.debug "#{response.body.inspect}"
        params[:cluster]["HDFS"] = params[:cluster]["Hadoop"]
        frameworks.each { |framework|
          cluster.cluster_frameworks.build(framework_id: framework[:id]) if params[:cluster][framework[:name]].to_i==1
        }
        uuid = nil
        response.header.each_header { |key, value| uuid = value.split(//).last(36).join if key =="location" }
        response.header.each_header { |key, value| Rails.logger.debug "#{key} => #{value}" }

        cluster.update_attribute(:uuid, uuid)
        cluster.update_attribute(:external_ip, 0)
        cluster.update_attribute(:state, "Deplyoing...")
        #ActionCable.server.broadcast "user_#{current_user[:id]}",
         #                            type: 1,
          #                           cluster: render_cluster(cluster)
        ClusterUpdateJob.perform_later(infrastructure, current_user[:id], cluster[:id], params[:cluster][:password])

        response = send_request(params[:cluster], infrastructure, uuid)
        response.header.each_header { |key, value| Rails.logger.debug "#{key} => #{value}" }

        sleep(1)
        redirect_to clusters_path
        return
      else
        cluster.delete
        flash[:danger] = "DISCO connection error"
        Rails.logger.debug "DISCO connection error"
        redirect_to clusters_new_path
        return
      end
    else
      flash[:warning] = "Cluster details were not filled correctly"
      Rails.logger.debug "Cluster details were not filled correctly"
      redirect_to clusters_new_path
      return
    end
  end

  # Method to delete chosen cluster
  def destroy
    uuid = params[:delete][:uuid]
    cluster = Cluster.find_by(uuid: uuid)
    infrastructure = Infrastructure.find(cluster.infrastructure_id)

    response = delete_req(infrastructure, params[:delete][:password], uuid)

    if response.code != "200"
      flash[:danger] = "DISCO connection error"
    else
      cluster.delete
      flash[:success] = "The cluster is being deleted"
    end

    redirect_to root_url
  end

  # Retrieves data and renders a form for a cluster creation
  # Called by AJAX Get request from dashboard
  def render_form
    @infrastructure_id = params[:infrastructure_id]
    if @infrastructure_id != "0"
      @frameworks = Framework.all
      @images     = Image.where(infrastructure_id: @infrastructure_id)
      @flavors    = Flavor.where(infrastructure_id: @infrastructure_id)
      @keypairs   = Keypair.where(infrastructure_id: @infrastructure_id)
    end

    respond_to do |format|
      format.js
    end
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
      @images          = Image.all
      @flavors         = Flavor.all
      render(partial: 'cluster', locals: { cluster:  cluster })
    end

    def value(val)
      val.to_i==1 ? "true" : "false"
    end

    def create_req(cluster, infrastructure, frameworks)
      uri     = URI.parse(ENV["disco_ip"])
      request = Net::HTTP::Post.new(uri)

      request.content_type         = "text/occi"
      request["Category"]          = 'haas; scheme="http://schemas.cloudcomplab.ch/occi/sm#"; class="kind";'
      request["X-Tenant-Name"]     = infrastructure[:tenant]
      request["X-Region-Name"]     = ENV["region"]
      request["X-User-Name"]       = infrastructure[:username]
      request["X-Password"]        = cluster[:password]

      master_image = Image.find(cluster[:master_image])
      request["X-Occi-Attribute"]  = 'icclab.haas.master.image="'+master_image.img_id+'",'
      slave_image = Image.find(cluster[:slave_image])
      request["X-Occi-Attribute"] += 'icclab.haas.slave.image="'+slave_image.img_id+'",'

      request["X-Occi-Attribute"] += 'icclab.haas.master.sshkeyname="'+cluster[:keypair]+'",'

      master_flavor = Flavor.find(cluster[:master_flavor])
      request["X-Occi-Attribute"] += 'icclab.haas.master.flavor="'+master_flavor.fl_id+'",'
      slave_flavor = Flavor.find(cluster[:slave_flavor])
      request["X-Occi-Attribute"] += 'icclab.haas.slave.flavor="'+slave_flavor.fl_id+'",'

      request["X-Occi-Attribute"] += 'icclab.haas.master.number="'+cluster[:master_num].to_s+'",'
      request["X-Occi-Attribute"] += 'icclab.haas.slave.number="'+cluster[:slave_num].to_s+'",'

      request["X-Occi-Attribute"] += 'icclab.haas.master.slaveonmaster="'+value(cluster[:slave_on_master])+'",'

      frameworks.each do |framework|
        if !framework.name.eql? "HDFS"
          request["X-Occi-Attribute"] += 'icclab.disco.frameworks.'+framework[:name].downcase
          request["X-Occi-Attribute"] += '.included="'+value(cluster[framework[:name]])+'",'
        end
      end

      request["X-Occi-Attribute"] += 'icclab.haas.master.withfloatingip="true"'

      Rails.logger.debug {"Cluster attributes: #{request["X-Occi-Attribute"].inspect}"}

      response = Net::HTTP.start(uri.hostname, uri.port) do |http|
        http.request(request)
      end

      response
    end

    def delete_req(infrastructure, password, uuid)
      uri  = URI.parse(ENV["disco_ip"]+uuid)

      request = Net::HTTP::Delete.new(uri)
      request.content_type     = "text/occi"
      request["Category"]      = 'haas; scheme="http://schemas.cloudcomplab.ch/occi/sm#"; class="kind";'
      request["X-Tenant-Name"] = infrastructure[:tenant]
      request["X-Region-Name"] = ENV["region"]
      request["X-User-Name"]   = infrastructure[:username]
      request["X-Password"]    = password

      response = Net::HTTP.start(uri.hostname, uri.port) do |http|
        http.request(request)
      end

      response
    end

    def send_request(cluster, infrastructure, uuid = '')
      url = ENV["disco_ip"]+uuid
      uri     = URI.parse(url)
      request = Net::HTTP::Get.new(uri)
      request["X-User-Name"]   = infrastructure[:username]
      request["X-Password"]    = cluster[:password]
      request["X-Tenant-Name"] = infrastructure[:tenant]
      request["X-Region-Name"] = ENV["region"]
      request["Accept"]        = "text/occi"
      response = Net::HTTP.start(uri.hostname, uri.port) do |http|
        http.request(request)
      end

      response
    end
end
