class TasksController < ApplicationController
  before_action :logged_in_user
  before_action do
    is_permitted?("task")
  end

  def index
    @tasks = Task.all
  end

  def new
    @task = Task.new
  end

  def create
    @group = Group.find(params[:task][:group_id])
    @task = @group.tasks.build(task_params)

    if @task.save
      flash[:success] = "The task #{@task.name} has been uploaded"
      redirect_to groups_path
    else
      flash[:danger] = "Failed to save and/or upload #{@task.name}"
      render 'new'
    end
  end

  def destroy
    @task = Task.find(params[:id])
    @task.destroy
    flash[:success] = "The task #{@task.name} has been deleted"
    redirect_to groups_path
  end

  private
    def task_params
      params.require(:task).permit(:name, :attachment)
    end
end
