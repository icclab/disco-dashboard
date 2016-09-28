class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  @@openstack = OpenStack::Connection.create ({
        username:   'kenz@zhaw.ch',
        api_key:    'algorithms1',
        auth_url:   'https://keystone.cloud.switch.ch:5000/v2.0',
        authtenant: 'kenz@zhaw.ch',
        region:     'ZH'
    })
end
