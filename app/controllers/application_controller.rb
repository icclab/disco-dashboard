class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper

  @@disco_ip = 'http://160.85.4.252:8888/haas/'
  @@openstack = ''

end
