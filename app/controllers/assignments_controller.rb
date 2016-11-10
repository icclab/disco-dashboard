class AssignmentsController < ApplicationController
  def create

  end

  def destroy
    cluster = Cluster.find(params[:cluster_id])
    assignment = cluster.assignments.find_by(user_id: params[:user_id])
    assignment.delete
  end
end
