class SessionsController < ApplicationController
  def new
  end

  def create
    session = params[:session]
    openstack = OpenStack::Connection.create ({
        username:   session[:username],
        api_key:    session[:password],
        auth_url:   session[:auth_url],
        authtenant: session[:tenant]
      })
    error if !openstack

    user = User.find_by(username: params[:session][:username].downcase)
    if user
      if user.authenticate(params[:session][:password])
        log_in user
        params[:session][:remember_me] == '1' ? remember(user) : forget(user)
        redirect_to root_path
      else
        error
      end
    else
      user = User.new(session_params.except(:remember_me))
      user[:disco_ip] = params[:session][:password]
      if user.save
        log_in user
        params[:session][:remember_me] == '1' ? remember(user) : forget(user)
        redirect_to root_path
      else
        error
      end
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to login_path
  end

  def error
    flash.now[:danger] = 'Invalid username/password combination'
    render 'new'
  end

  private
    def session_params
      params.require(:session).permit(:username, :password, :auth_url, :tenant, :remember_me)
    end
end
