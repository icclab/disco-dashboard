##
# Infrastructure model relationships, validations, adapters and underlying methods.
class Infrastructure < ApplicationRecord
  belongs_to :user
  has_many :clusters
  has_many :images,   dependent: :destroy
  has_many :flavors,  dependent: :destroy
  has_many :keypairs, dependent: :destroy

  validates :name,     presence: true, length: { maximum: 255 }
  validates :username, presence: true
  validates :auth_url, presence: true
  validates :tenant,   presence: true
  validates :region,   presence: true
  validates :provider, presence: true

  ##
  # Adapter module contains modules for different infrastructure providers with its own implementation of methods such as:
  #   - authenticate(credentials) => creates a connection between infrastructure and object
  #   - get_images(connection)    => gets list of images from given infrastructure connection
  #   - get_flavors(connection)   => gets list of flavors from given infrastructure connection
  #   - get_keypair(connection)   => gets list of keypairs from given infrastructure connection
  #
  # Adapter can be easily extended with new infrastructure providers (e.g. Cloudstack), and its own methods can be implemented.
  module Adapter
    module Openstack
      class << self
        def authenticate(credentials)
          OpenStack::Connection.create ({
            username:   credentials[:username],
            api_key:    credentials[:password],
            auth_url:   credentials[:auth_url],
            authtenant: credentials[:tenant],
            region:     credentials[:region]
          })
        end

        def get_images(connection)
          connection.list_images
        end

        def get_flavors(connection)
          connection.list_flavors
        end

        def get_keypairs(connection)
          connection.keypairs
        end
      end
    end
=begin
    module Cloudstack
      class << self
        def authenticate(credentials)

        end

        def get_images(connection)

        end

        def get_flavors(connection)

        end

        def get_keypairs(connection)

        end
      end
    end
=end
  end

  def authenticate(credentials)
    self.adapter.authenticate credentials
  end

  def get_images(connection)
    self.adapter.get_images connection
  end

  def get_flavors(connection)
    self.adapter.get_flavors connection
  end

  def get_keypairs(connection)
    self.adapter.get_keypairs connection
  end

  ##
  # Returns chosen infrastructure object's provider
  def adapter
    Infrastructure::Adapter.const_get(self.provider.capitalize)
  end
end
