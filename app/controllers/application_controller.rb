class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper

  @@openstack = OpenStack::Connection.create ({
        username:   'disco',
        api_key:    '89,@924;9299[>6',
        auth_url:   'http://lisa.cloudcomplab.ch:5000/v2.0',
        authtenant: 'disco'
    })

end
