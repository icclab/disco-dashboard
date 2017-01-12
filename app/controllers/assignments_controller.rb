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
