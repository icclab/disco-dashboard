class AssignmentsController < ApplicationController
  before_action :logged_in_user
  before_action do
    is_permitted?("group")
  end

  def new
    @assignment = Assignment.new
    @users = User.all.except(current_user)
  end

  def create
    user = User.find_by(email: params[:assignment][:email])
    group = Group.find(params[:assignment][:group_id])
    if !group.assignments.find_by(user_id: user.id)
      group.assignments.create(user: user)
    end
    redirect_to groups_path
  end

  def destroy
    group = Group.find(params[:group_id])
    user_id = params[:user_id]
    assignment = group.assignments.find_by(user_id: user_id)
    if assignment.delete
      redirect_to groups_path
    end
  end
end
