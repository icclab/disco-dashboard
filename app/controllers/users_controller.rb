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

class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :show, :edit, :update]
  before_action :correct_user,   only: [:index, :show, :edit, :update]
  before_action :admin_user,     only: [:index, :destroy]

  include SessionsHelper

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
    @usertypes = User::Usertype.constants
  end

  def create
    @usertypes = User::Usertype.constants
    @user = User.new(user_params)
    if @user.save
      log_in @user
      redirect_to root_url
    else
      render 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    redirect_to users_url
  end

  private
    def user_params
      params.require(:user).permit(:email, :role, :password, :password_confirmation)
    end

    # Confirm the correct user.
    def correct_user
      @user = User.find(params[:id])
      if !current_user?(@user)
        flash[:warning] = "Access Denied"
        redirect_to root_url
      end
    end

    def admin_user
      if !current_user.admin?
        flash[:warning] = "Access only for admin_user"
        redirect_to root_url
      end
    end
end
