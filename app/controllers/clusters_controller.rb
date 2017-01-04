class ClustersController < ApplicationController
  # Ensures that only logged in user can access to these methods
  before_action :logged_in_user
  before_action do
    is_permitted?("cluster")
  end

  include DiscoHelper

  def index
    @clusters = current_user.clusters.all
    @groups = current_user.groups.all
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

    redirect_to clusters_path
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
end
