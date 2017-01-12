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
  before_action :logged_in_user
  before_action do
    is_permitted?("infrastructure")
  end

  def index
    @infrastructures = current_user.infrastructures.all if current_user.infrastructures.any?
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
    if @infrastructure.save && connection = @infrastructure.authenticate(params[:infrastructure])
      save_images   @infrastructure.get_images   connection
      save_flavors  @infrastructure.get_flavors  connection
      save_keypairs @infrastructure.get_keypairs connection
      flash[:success] = "New infrastructure was added successfully"
      redirect_to infrastructures_path
    else
      flash[:danger] = "Please, fill all fields with correct information"
      render 'new'
    end
  end

  def destroy
    Infrastructure.find(params[:id]).destroy
    redirect_to infrastructures_path
  end

  private
    def infrastructure_params
      params.require(:infrastructure).permit(:name, :username, :tenant, :auth_url, :region, :provider)
    end

    def save_images(images)
      images.each do |img|
        image = @infrastructure.images.build(
          img_id: img[:id],
          name:   img[:name],
          size:   img[:minDisk] )

        image.save
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
