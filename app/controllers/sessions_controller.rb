class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(username: params[:session][:username].downcase)
    if user
      if user.authenticate(params[:session][:password])
        log_in user
        params[:session][:remember_me] == '1' ? remember(user) : forget(user)
        redirect_to root_path
      else
        flash.now[:danger] = 'Invalid username/password combination'
        render 'new'
      end
    else
      user = User.new(session_params.except(:remember_me))

      if user.save
        log_in user
        params[:session][:remember_me] == '1' ? remember(user) : forget(user)
        redirect_to root_path
      else
        render 'new'
      end
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to login_path
  end

  private
    def session_params
      params.require(:session).permit(:username, :password, :auth_url, :tenant, :remember_me)
    end
end
