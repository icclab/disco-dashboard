#
# Copyright (c) 2015. Zuercher Hochschule fuer Angewandte Wissenschaften
#  All Rights Reserved.
#
#     Licensed under the Apache License, Version 2.0 (the "License"); you may
#     not use this file except in compliance with the License. You may obtain
#     a copy of the License at
#
#          http://www.apache.org/licenses/LICENSE-2.0
#
#     Unless required by applicable law or agreed to in writing, software
#     distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#     WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#     License for the specific language governing permissions and limitations
#     under the License.
#

#
#     Author: Saken Kenzhegulov,
#     URL: https://github.com/skenzhegulov
#

##
# Infrastructure model relationships, validations, adapters and underlying methods.
class Infrastructure < ApplicationRecord
  belongs_to :user
  has_many :clusters
  has_many :images,   dependent: :destroy
  has_many :flavors,  dependent: :destroy

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

  ##
  # Returns chosen infrastructure object's provider
  def adapter
    Infrastructure::Adapter.const_get(self.provider.capitalize)
  end
end
