class UsersController < ApplicationController
  def login
    @user = User.new
  end

  def create
    @user = User.find_by(username: params[:username])
    if @user
    else
      @user = User.new(user_params)
      if @user.save
      else
        render 'login'
      end
    end
  end

  private
    def user_params
      params.require(:user).permit(:name, :password, :auth_url, :tenant, :disco_ip)
    end

    # Confirm the correct user.
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end
end
