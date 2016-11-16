class Infrastructure < ApplicationRecord
  belongs_to :user
  has_many :clusters, dependent: :destroy
  has_many :images,   dependent: :destroy
  has_many :flavors,  dependent: :destroy
  has_many :keypairs, dependent: :destroy

  validates :name,     presence: true, length: { maximum: 255 }
  validates :username, presence: true
  validates :auth_url, presence: true
  validates :tenant,   presence: true

  module Adapter
    module Openstack
      class << self
        def authenticate(credentials)
          OpenStack::Connection.create ({
            username:   credentials[:username],
            api_key:    credentials[:password],
            auth_url:   credentials[:auth_url],
            authtenant: credentials[:tenant],
            region:     ENV['region']
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

  def adapter
    return @adapter if @adapter
    self.adapter = :openstack
    @adapter
  end

  def adapter=(adapter)
    puts adapter
    @adapter = Infrastructure::Adapter.const_get(adapter.to_s.capitalize)
  end
end
