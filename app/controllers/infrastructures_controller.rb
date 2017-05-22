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

class InfrastructuresController < ApplicationController
  # DiscoHelper is included to be able to send create/delete/retrieve requests from this controller.
  include DiscoHelper

  before_action :logged_in_user
  before_action do
    is_permitted?("infrastructure")
  end

  def index
    if current_user.is_admin?
      @infrastructures = Infrastructure.all
      @clusters = Cluster.all
    else
      @infrastructures = current_user.infrastructures.all if current_user.infrastructures.any?
      @clusters = current_user.clusters.all if current_user.clusters.any?
    end

  end

  def show
    @infrastructure = Infrastructure.find(params[:infrastructure][:id])
  end

  def new
    @infrastructure = Infrastructure.new
    @adapters = Infrastructure::Adapter.constants
  end

  def create
    @infrastructure = current_user.infrastructures.build(infrastructure_params)
    @adapters = Infrastructure::Adapter.constants
    begin
      if @infrastructure.save && connection = @infrastructure.authenticate(params[:infrastructure])
        save_images   @infrastructure.get_images   connection
        save_flavors  @infrastructure.get_flavors  connection
        flash[:success] = "New infrastructure was added successfully"
        redirect_to infrastructures_path
      else
        flash[:danger] = "Please, fill all fields with correct information"
        @infrastructure.delete
        render 'new'
      end
    rescue Exception
      flash[:danger] = "Please, fill all fields with correct information"
      render 'new'
    end
  end

  def update
    @infrastructure = current_user.infrastructures.find(params[:id])
    credentials = {   username:   @infrastructure.username,
                      password:    params[:infrastructure][:password],
                      auth_url:   @infrastructure.auth_url,
                      authtenant: @infrastructure.tenant,
                      region:     @infrastructure.region
    }
    begin
      connection = @infrastructure.authenticate(credentials)
      if connection
        current_user.images.where(infrastructure_id: params[:id]).delete_all
        current_user.flavors.where(infrastructure_id: params[:id]).delete_all

        save_images   @infrastructure.get_images   connection
        save_flavors  @infrastructure.get_flavors  connection
        flash[:success] = "Infrastructure was reloaded successfully"
        redirect_to infrastructures_path
      else
        flash[:danger] = "Wrong password provided"
        redirect_to infrastructures_path
      end
    rescue Exception
      flash[:danger] = "Wrong password provided"
      redirect_to infrastructures_path
    end

  end

  def destroy


    # OpenStack::Connection.create ({
    #     username:   credentials[:username],
    #     api_key:    credentials[:password],
    #     auth_url:   credentials[:auth_url],
    #     authtenant: credentials[:tenant],
    #     region:     credentials[:region]


    infrastructure_to_delete = Infrastructure.find(params[:delete][:id].to_i)
    begin
      if OpenStack::Connection.create(:username=>infrastructure_to_delete.username,
                                            :api_key=>params[:delete][:password].to_s,
                                            :auth_url=>infrastructure_to_delete.auth_url,
                                            :tenant=>infrastructure_to_delete.tenant,
                                            :region=>infrastructure_to_delete.region)
        # the user ID has to be checked - else, a different user's infrastructures might be deleted
        if infrastructure_to_delete.user_id==current_user.id


          # begin
          #   if params[:delete][:deleteclusters]=="true"

              clusters_to_delete = Cluster.where(infrastructure_id: params[:delete][:id].to_i)
              # clusters_to_delete.destroy_all
              clusters_to_delete.find_each do |cluster|
                begin
                  delete_req(infrastructure_to_delete, params[:delete][:password], cluster.uuid)
                rescue
                end

                cluster.delete
              end
            # end
          # rescue Exception => exception
          #   puts exception.to_s
          # end


          current_user.images.where(infrastructure_id: params[:delete][:id]).delete_all
          current_user.flavors.where(infrastructure_id: params[:delete][:id]).delete_all

          infrastructure_to_delete.destroy
        end
      end
    rescue
      flash[:danger] = "Wrong password provided"
    end

    redirect_to infrastructures_path
  end

  private
    def infrastructure_params
      params.require(:infrastructure).permit(:name, :username, :tenant, :auth_url, :region, :provider)
    end

    def save_images(images)
      images.each do |img|0
        image = @infrastructure.images.build(
          img_id: img[:id],
          name:   img[:name],
          size:   img[:minDisk] )
        image.save
      end
    end

    def save_flavors(flavors)
      flavors.each do |flv|
        # minimum memory size should be at least 4G for used flavors
        if flv[:ram]>4000
          flavor = @infrastructure.flavors.build(
            fl_id: flv[:id],
            name:  flv[:name],
            vcpus: flv[:vcpus],
            ram:   flv[:ram],
            disk:  flv[:disk] )
          flavor.save
        end
      end
    end
end
