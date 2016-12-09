class AssignmentsController < ApplicationController

  def create
    user = User.find_by(email: params[:assignment][:email])
    group = Group.find(params[:assignment][:group_id])
    if !group.assignments.find_by(user_id: user.id) && group.assignments.create(user: user)
      ActionCable.server.broadcast "user_#{current_user[:id]}",
                                     type: 3,
                                     user: render_assignment(user, cluster.id)
    end
  end

  def destroy
    group = Group.find(params[:group_id])
    user_id = params[:user_id]
    assignment = group.assignments.find_by(user_id: user_id)
    if assignment.delete
      ActionCable.server.broadcast "user_#{current_user[:id]}",
                                     type: 4,
                                     userId: user_id,
                                     clusterId: cluster.id
    end
  end

  private
    def render_assignment(user, cluster_id)
      render(partial: 'assignment', locals: { cluster_id:  cluster_id, user: user })
    end
end
