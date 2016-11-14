class AssignmentsController < ApplicationController
  def create
    user = User.find_by(email: params[:assignment][:email])
    cluster = Cluster.find(params[:assignment][:cluster_id])
    if !cluster.assignments.find_by(user_id: user.id) && cluster.assignments.create(user: user)
      ActionCable.server.broadcast "cluster_#{current_user[:id]}",
                                     type: 3,
                                     user: render_assignment(user, cluster.id)
    end
  end

  def destroy
    cluster = Cluster.find(params[:cluster_id])
    assignment = cluster.assignments.find_by(user_id: params[:user_id])
    assignment.delete
  end

  private
    def render_assignment(user, cluster_id)
      render(partial: 'assignment', locals: { cluster_id:  cluster_id, user: user })
    end
end
