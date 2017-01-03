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
    @usertypes = User::Usertype.constants
  end

  def create
    @user = User.new(user_params)
    @user.usertype = params[:user][:type]
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
      params.require(:user).permit(:email, :password, :password_confirmation)
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
