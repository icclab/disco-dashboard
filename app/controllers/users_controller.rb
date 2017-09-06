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
    @usertypes.delete(:Admin)
  end

  def create
    @usertypes = User::Usertype.constants
    @user = User.new(user_params)
    @usertypes = User::Usertype.constants
    if @user.save
      log_in @user
      redirect_to root_path(:registered => "true")
      # redirect_to root_url
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

  # Handle entered email address for password recovery - if email address
  # doesn't exist, redirecting to login page. Otherwise, an email with the
  # recovery code is sent to the email address.
  def sendpasswordemail
    pwd_recovery_user = User.find_by_email(params[:email].downcase)
    if pwd_recovery_user==nil
      flash[:danger] = "Username "+params[:email].downcase+" not found!"
      redirect_to "/login"
    else
      random_string = (0...8).map { (65 + rand(26)).chr }.join
      User.where(:id => pwd_recovery_user.id).update_all(password_reset: random_string)
      disco_recovery_url = ENV['disco_recovery_url']
      mail_subject = "DISCO password recovery"
      mail_text = "Did you forget your DISCO password? Do not worry, just go to "+disco_recovery_url+" and enter the code "+random_string+" in the indicated field."
      ApplicationMailer.send_mail(params[:email].downcase, mail_subject, mail_text).deliver
      @email = params[:email].downcase
      render "entercodepage"
    end
  end

  # checking whether entered code corresponds to username - if yes, a new
  # password can be entered, else, redirect to /forgottenpassword
  def newpassword
    entered_code = params[:generatedcode]
    email = params[:email].downcase

    pwd_recovery_user = User.find_by_email(email)
    if pwd_recovery_user!=nil && pwd_recovery_user.password_reset==entered_code
      @email = email
      @generatedcode = entered_code
      render "newpassword"
    else
      flash[:danger] = "Username doesn't exist or wrong code provided."
      redirect_to "/forgottenpassword"
    end
  end

  # save the entered password to database and delete generated recovery code
  def savepassword
    generated_code = params[:generatedcode]
    email = params[:email].downcase
    newpassword = params[:newpassword]
    repnewpassword = params[:repnewpassword]
    if newpassword!=repnewpassword
      flash[:danger] = "Given passwords don't match - please try again!"
      @email = email
      @generatedcode = generated_code
      render "newpassword"
    else
      # password_reset must be set to NIL (and not to empty string!) -
      # otherwise, the old string or an empty string could permit password
      # change
      User.where(:email => email, :password_reset => generated_code).update_all(:password_digest => User.digest(newpassword),:password_reset => NIL)
      redirect_to "/login"
    end
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
