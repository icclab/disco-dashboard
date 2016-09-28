class PagesController < ApplicationController

  helper_method :get_image, :get_flavor

  def dashboard
    @servers = @@openstack.list_servers_detail
    @images  = @@openstack.list_images
    @flavors = @@openstack.list_flavors
  end

  def login
  end

  def get_image(id)
    @@openstack.get_image(id)
  end

  def get_flavor(id)
    @@openstack.get_flavor(id)
  end
end
