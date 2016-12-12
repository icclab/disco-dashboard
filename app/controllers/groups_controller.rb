class GroupsController < ApplicationController
  before_action :logged_in_user

  def index
    @groups = current_user.groups.all
  end

  def show
    @group = Group.find(params[:group_id])
  end

  def new
    @group = Group.new
  end

  def create

  end

  def destroy

  end

  def associate_cluster
    group = Group.find(params[:assignment][:group_id])
    cluster = Cluster.find(params[:assignment][:cluster_id])
    group.clusters << cluster

    redirect_to clusters_path
  end

  def deassociate_cluster
    group = Group.find(params[:group_id])
    cluster = Cluster.find(params[:cluster_id])
    group.clusters.delete(cluster)
  end

  private
    def group_params

    end
end
