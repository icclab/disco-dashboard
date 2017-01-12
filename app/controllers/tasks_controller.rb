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
