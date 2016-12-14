class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  #rescue_from StandardError, :with => :render_500

  include SessionsHelper

  def not_found
    render :file => "#{Rails.root}/public/404.html", :status => 404
  end

  def render_500(exception)
    @exception = exception
    render :file => "#{Rails.root}/public/500.html", :status => 500
  end

  private
    def logged_in_user
      user_id = cookies.signed[:user_id]
      user = User.find_by(id: user_id)
      if user
        log_in user
      end
      unless logged_in?
        redirect_to login_url
      end
    end

    def is_professor?
      redirect_to root_url if current_user.usertype != 1
    end
end
