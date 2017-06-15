#
# Copyright (c) 2015. Zuercher Hochschule fuer Angewandte Wissenschaften
#  All Rights Reserved.
#
#     Licensed under the Apache License, Version 2.0 (the "License"); you may
#     not use this file except in compliance with the License. You may obtain
#     a copy of the License at
#
#          http://www.apache.org/licenses/LICENSE-2.0
#
#     Unless required by applicable law or agreed to in writing, software
#     distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#     WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#     License for the specific language governing permissions and limitations
#     under the License.
#

#
#     Author: Saken Kenzhegulov,
#     URL: https://github.com/skenzhegulov
#

##
# ClusterController is responsible for the clusters' retrieval, creation, and deletion.
class ClustersController < ApplicationController
  # DiscoHelper is included to be able to send create/delete/retrieve requests from this controller.
  include DiscoHelper
  # ClusterHelper is included to access to the 'update_clusters' method.
  include ClusterHelper
  # Ensures that only logged in user can access to these methods.
  before_action :logged_in_user
  # Ensures that current_user has appropriate permission to access to the controller methods.
  before_action do
    if params[:action]!='sshprivatekey'
      is_permitted?("cluster")
    end
  end
  # Ensures that cluster details are up to date before showing them to the user.
  before_action :update_clusters, only: [:index, :show]

  # Retrieves current user clusters and groups from database
  def index
    if current_user.is_admin?
      @clusters = Cluster.all
      @groups = Group.all
    else
      @clusters = current_user.clusters.all
      @groups   = current_user.groups.all
    end
  end

  ##
  # Retrieves current user infrastructures and puts them to the adapter dictionary(hash)
  # so user can select needed infrastructure
  def new
    @infrastructures = current_user.infrastructures.all
    @adapters        = { "Choose" => 0 }
    @infrastructures.each { |inf| @adapters[inf.name] = inf.id } if @infrastructures
  end

  ##
  # (This is not used currently)
  # Retrieves selected cluster from database
  def show
    @cluster = Cluster.where(:uuid => params[:uuid])[0]
    @groups   = current_user.groups.all
  end

  ##
  # returns the SSH private key for the selected cluster for login to the master
  def sshprivatekey
    @cluster = Cluster.where(:uuid => params[:uuid])[0]
    send_data(@cluster.ssh_private_key.gsub('\n',"\n").chomp("%"), :filename => @cluster.name+".id_rsa")
  end

  ##
  # Creates new cluster entity and sends cluster create request to DISCO
  # if everything filled correctly(cluster parameters and infrastructure password).
  # After success redirects to the clusters page.
  # After failure redirects to the new cluster creation page.
  # Failure may occure since:
  #   1) Cluster parameters were not filled correctly,
  #      in this case: "Cluster details were not filled correctly" warning will show up.
  #   2) Incorrect password was typed or DISCO connection problem occured,
  #      in this case: "DISCO connection error" warning will show up.
  def create
    # Retrieves chosen infrastructure and creates new cluster entity which belongs to that infrastructure
    infrastructure = Infrastructure.find(params[:cluster][:infrastructure_id])
    cluster = infrastructure.clusters.build(cluster_params)
    # Retrieves chosen master and slave image from database to reference them from new cluster entity
    cluster.master_image = Image.find(params[:cluster][:master_image])
    cluster.slave_image  = Image.find(params[:cluster][:slave_image])
    # Retrieves chosen master and slave flavor from database to reference them from new cluster entity
    cluster.master_flavor = Flavor.find(params[:cluster][:master_flavor])
    cluster.slave_flavor  = Flavor.find(params[:cluster][:slave_flavor])

    # save image name and flavor informations for both master and slaves directly with cluster
    master_image = Image.find(params[:cluster][:master_image])
    slave_image  = Image.find(params[:cluster][:slave_image])
    master_flavor = Flavor.find(params[:cluster][:master_flavor])
    slave_flavor  = Flavor.find(params[:cluster][:slave_flavor])
    cluster.master_image_name = master_image[:name]
    cluster.slave_image_name = slave_image[:name]
    cluster.slave_flavor_memory = slave_flavor[:ram]
    cluster.slave_flavor_vcpu = slave_flavor[:vcpus]
    cluster.slave_flavor_disk = slave_flavor[:disk]
    cluster.master_flavor_memory = master_flavor[:ram]
    cluster.master_flavor_vcpu = master_flavor[:vcpus]
    cluster.master_flavor_disk = master_flavor[:disk]
    cluster.is_suspended = false

    # If new cluster is properly configured it will be saved in database
    if cluster.save
      # Then we send request to the DISCO to create a new cluster
      response = create_req(params[:cluster], infrastructure)
      if response.code == "201"
        # If the request was accepted, continues to add chosen framework(s) to the new cluster entity
        get_frameworks cluster
        # Gets cluster uuid, so we can get detailed information from the DISCO of the current cluster
        cluster.get_uuid response.header


        # this is a hotfix for the case that cluster has been inserted into database but not "sent" to DISCO
        if cluster.read_attribute('uuid') == "" or cluster.read_attribute('uuid') == nil
          cluster.delete
        else

          # Starts a background job which will update state of the cluster as deployment proceeds
          ClusterUpdateJob.perform_later(infrastructure, current_user[:id], cluster[:id], params[:cluster][:password])

        end


        sleep(1)
        redirect_to clusters_path
        return
      else
        # In case of failed DISCO connection, new cluster is deleted from database
        cluster.delete
        flash[:danger] = "DISCO connection error"
        Rails.logger.debug "DISCO connection error"
      end
    else
      flash[:warning] = "Cluster details were not filled correctly"
      Rails.logger.debug "Cluster details were not filled correctly"
    end
    # Retrieves infrastructures and putting them to adapters so in case of failure in creation, we can render them again
    @infrastructures = current_user.infrastructures.all
    @adapters        = { "Choose" => 0 }
    @infrastructures.each { |inf| @adapters[inf.name] = inf.id } if @infrastructures
    redirect_to clusters_new_path
  end

  def update
    if params[:put][:action]=="suspend"
      cluster = Cluster.find_by(uuid: params[:put][:uuid])
      cluster.suspend(params[:put][:password])
    elsif params[:put][:action]=="resume"
      cluster = Cluster.find_by(uuid: params[:put][:uuid])
      cluster.resume(params[:put][:password])
    end

    redirect_to clusters_path
  end

  ##
  # Deletes chosen cluster from stack and database if success response returned from DISCO framework
  def destroy
    # Chosen cluster is retrieved from the database according to its uuid
    uuid = params[:delete][:uuid]
    if uuid==""
      self.current_user.clusters.all.each do |cluster|
        if cluster.read_attribute('uuid')=="" or cluster.read_attribute('uuid')==nil
          cluster.delete
        end
      end
    end
    begin
      cluster = Cluster.find_by(uuid: uuid)
      # Retrieves cluster's infrastructure to get credentials
      infrastructure = Infrastructure.find(cluster.infrastructure_id)

      # Sends DISCO delete request using credentials, password, and cluster uuid
      response = delete_req(infrastructure, params[:delete][:password], uuid)

      # response code 200 indicates that cluster was removed successfully
      # response code 400 indicates that cluster doesn't exist anymore and should be removed from the dashboard
      if response.code == "200"
        # After a successful delete request cluster will be deleted from database
        cluster.delete
        flash[:success] = "The cluster is being deleted"
      elsif response.code == "400"
        # response code 400
        cluster.delete
        flash[:warning] = "Given cluster not found - maybe, the dashboard was bypassed - removing cluster from database"
      elsif response.code == "666"
        # DISCO is not online
        flash[:danger] = "DISCO is not online"
      else
        flash[:danger] = "DISCO connection error"
      end
    rescue
      puts "Cluster could not be found"
    end
    redirect_to clusters_path
  end

  ##
  # Retrieves data and renders a form for a cluster creation
  # Called by AJAX Get request from dashboard
  def render_form
    @infrastructure_id = params[:infrastructure_id]
    if @infrastructure_id != "0"
      @frameworks = Framework.all
      @images     = Image.where(infrastructure_id: @infrastructure_id)
      @flavors    = Flavor.where(infrastructure_id: @infrastructure_id)
    end

    # Ubuntu Trusty (14.04) should be pre-selected - determine ID for view
    begin
      ubuntutrusty = @images.where('"name" LIKE "%ubuntu%14%04%"')[0]
      @selectedimage = ubuntutrusty.id
    rescue
      # Ubuntu Trusty not found
    end

    respond_to do |format|
      format.js
    end
  end

  private
    ##
    # Grants a permit for chosen parameters
    def cluster_params
      params.require(:cluster).permit(:name,  :uuid,  :state,
                                      :slave_num,
                                      :slave_on_master)
    end

    ##
    # Adds chosen frameworks to the given cluster
    def get_frameworks(cluster)
      frameworks = Framework.all
      params[:cluster]["HDFS"] = params[:cluster]["Hadoop"]
      frameworks.each { |framework|
        cluster.cluster_frameworks.build(framework_id: framework[:id]) if params[:cluster][framework[:name]].to_i==1
      }
    end
end
