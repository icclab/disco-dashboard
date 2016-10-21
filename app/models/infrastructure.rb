class Infrastructure < ApplicationRecord
  belongs_to :user
  has_many :clusters, dependent: :destroy
  has_many :images, dependent: :destroy
  has_many :flavors, dependent: :destroy

  module Adapter
    module Openstack
      class << self
        def authenticate(password)
          OpenStack::Connection.create ({
            username:   self.username,
            api_key:    password,
            auth_url:   self.auth_url,
            authtenant: self.tenant
          })
        end

        def get_images(connection)
          connection.get_images
        end

        def get_flavors
          connection.get_flavors
        end
      end
    end

    module Cloudstack
      class << self
        def authenticate

        end

        def get_images

        end

        def get_flavors

        end
      end
    end

    def authenticate
      self.adapter.authenticate
    end

    def get_images
      self.adapter.get_images
    end

    def get_flavors
      self.adapter.get_flavors
    end

    def adapter
      return @adapter if @adapter
      self.adapter = :openstack
      @adapter
    end

    def adapter=(adapter)
      @adapter = Infrastructure::Adapter.const_get(adapter.to_s.capitalize)
    end
  end
end
