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
    email = params[:assignment][:email]
    group_id = params[:assignment][:group_id]

    # is given email address just one address or CSV?
    if email.include?(",")

      # multiple email addresses
      emails = email.split(",")
      for cur_email in emails
        # handle each email separately
        find_user_and_create_if_not_existing(cur_email)
        associate_user_to_group(cur_email, group_id)
      end
    else
      # just one email address procedure as usual
      find_user_and_create_if_not_existing(email)
      associate_user_to_group(email, group_id)
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

  private

  # generate random string
  def generate_code(number)
    charset = Array('A'..'Z') + Array('a'..'z')
    Array.new(number) { charset.sample }.join
  end

  # associate user to group; at this point, no user existence checking done anymore
  def associate_user_to_group(user_email, group_id)
    user = User.find_by(email: user_email)
    group = Group.find(group_id)
    if !group.assignments.find_by(user_id: user.id)
      group.assignments.create(user: user)
    end
  end

  # new user will be created
  def find_user_and_create_if_not_existing(email)
    user = User.find_by(email: email)
    if user==nil
      #TODO: currently, email address is taken as password - has to be changed
      user = User.new({"email" => email, "role" => "Student", "password" => email})
      user.save
    end
    return user
  end
end
