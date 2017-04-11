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
    @infrastructures = current_user.infrastructures.all if current_user.infrastructures.any?

    @clusters = current_user.clusters.all if current_user.clusters.any?
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
        save_keypairs @infrastructure.get_keypairs connection
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
#        if (img[:name].downcase().include? "ubuntu") && (img[:name].include? "14.04")
          image = @infrastructure.images.build(
            img_id: img[:id],
            name:   img[:name],
            size:   img[:minDisk] )
          image.save
#        end
      end
    end

    def save_flavors(flavors)
      flavors.each do |flv|
        flavor = @infrastructure.flavors.build(
          fl_id: flv[:id],
          name:  flv[:name],
          vcpus: flv[:vcpus],
          ram:   flv[:ram],
          disk:  flv[:disk] )

        flavor.save
      end
    end

    def save_keypairs(keypairs)
      keypairs.each do |key, value|
        keypair = @infrastructure.keypairs.build(
          name: value[:name]
        ) if !value[:fingerprint].eql? ENV["fingerprint"]

        keypair.save if keypair
      end
    end
end
