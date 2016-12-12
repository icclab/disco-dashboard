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
    @group = Group.new(group_params)
    if @group.save
      group.assignments.create(user: current_user)
      redirect_to groups_path
    else
      render 'new'
    end
  end

  def destroy
    @group = Group.find(params[:id])
    @group.destroy
    redirect_to groups_path
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
    cluster.update_attribute(:group_id, nil)

    redirect_to clusters_path
  end

  private
    def group_params
      params.require(:group).permit(:name, :desc)
    end
end
