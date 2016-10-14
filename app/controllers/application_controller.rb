class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper

  @@disco_ip = 'http://160.85.4.252:8888/haas/'

  private
    def logged_in_user
      user_id = cookies.signed[:user_id]
      user = User.find_by(id: user_id)
      if user && user.authenticated?(cookies[:remember_token])
        log_in user
      end
      unless logged_in?
        redirect_to login_url
      end
    end

    def authenticate_to_openstack
      @@openstack = OpenStack::Connection.create ({
        username:   current_user[:username],
        api_key:    current_user[:disco_ip],
        auth_url:   current_user[:auth_url],
        authtenant: current_user[:tenant]
      })
    end

    def send_request(uuid = '', type = 'text')
      url = 'http://160.85.4.252:8888/haas/'
      url += uuid if uuid
      uri     = URI.parse(url)
      request = Net::HTTP::Get.new(uri)
      request["X-User-Name"]   = current_user[:username]
      request["X-Password"]    = current_user[:disco_ip]
      request["X-Tenant-Name"] = current_user[:tenant]
      request["Accept"]        = type == "json" ? "application/occi+json" : "text/occi"
      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
        http.request(request)
      end
      return response
    end

end
