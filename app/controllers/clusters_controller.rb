class ClustersController < ApplicationController
  include DiscoHelper
  include ClusterHelper
  # Ensures that only logged in user can access to these methods
  before_action :logged_in_user
  before_action :update_clusters, only: [:index, :show]
  before_action do
    is_permitted?("cluster")
  end

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

    infrastructure = Infrastructure.find(params[:cluster][:infrastructure_id])
    cluster = infrastructure.clusters.build(cluster_params)

    cluster.master_image = Image.find(params[:cluster][:master_image])
    cluster.slave_image  = Image.find(params[:cluster][:slave_image])

    cluster.master_flavor = Flavor.find(params[:cluster][:master_flavor])
    cluster.slave_flavor  = Flavor.find(params[:cluster][:slave_flavor])

    if cluster.save
      # If new cluster is properly configured then we send request to the DISCO
      # to create a new cluster
      response = create_req(params[:cluster], infrastructure)
      if response.code == "201"
        get_frameworks cluster
        cluster.get_uuid response.header

        ClusterUpdateJob.perform_later(infrastructure, current_user[:id], cluster[:id], params[:cluster][:password])

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
                                      :master_num,    :slave_num,
                                      :slave_on_master)
    end

    def get_frameworks(cluster)
      frameworks = Framework.all
      params[:cluster]["HDFS"] = params[:cluster]["Hadoop"]
      frameworks.each { |framework|
        cluster.cluster_frameworks.build(framework_id: framework[:id]) if params[:cluster][framework[:name]].to_i==1
      }
    end
end
