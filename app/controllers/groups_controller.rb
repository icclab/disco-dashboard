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
# GroupsController is responsible for the groups' retrieval, creation, and deletion.
class GroupsController < ApplicationController
  before_action :logged_in_user
  before_action except: [:index, :show] do
    is_permitted?("group")
  end

  ##
  # Retrieves current user's groups
  def index
    @groups = current_user.groups.all
  end

  ##
  # (Currently, not used on dashboard, but can be used as extension in the future)
  # Retrieves chosen group
  def show
    @group = Group.find(params[:group_id])
  end

  ##
  # Creates new group model object for the form
  def new
    @group = Group.new
  end

  ##
  # Creates new group model according to the passed parameters,
  # and tries to save new group to the database.
  # After a successful save, assigns current group to the user who created it,
  #  and redirects to groups page.
  # After a failed save, renders 'new' view again, with occured errors.
  def create
    @group = Group.new(group_params)
    if @group.save
      @group.assignments.create(user: current_user)
      flash[:success] = "Group '#{group.name}' was created successfully."
      redirect_to groups_path
    else
      flash[:warning] = "Please, fill all required fields."
      render 'new'
    end
  end

  ##
  # Deletes chosen group from the database and render groups view
  def destroy
    @group = Group.find(params[:id])
    @group.destroy
    redirect_to groups_path
  end

  ##
  # Associates chosen cluster with chosen group
  def associate_cluster
    group = Group.find(params[:assignment][:group_id])
    cluster = Cluster.find(params[:assignment][:cluster_id])
    group.clusters << cluster

    redirect_to clusters_path
  end

  ##
  # Deassociates chosen cluster from associated group
  def deassociate_cluster
    group = Group.find(params[:group_id])
    cluster = Cluster.find(params[:cluster_id])
    group.clusters.delete(cluster)
    cluster.update_attribute(:group_id, nil)

    redirect_to clusters_path
  end

  private
    ##
    # Get permits for the required params
    def group_params
      params.require(:group).permit(:name, :desc)
    end
end
