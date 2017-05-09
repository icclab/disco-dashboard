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

include DiscoHelper

##
# Cluster model shows all its relationship with other models,
# model validations, and underlying methods and logic
class Cluster < ApplicationRecord
  belongs_to :infrastructure
  belongs_to :group, optional: true
  belongs_to :master_image,  class_name: 'Image'
  belongs_to :slave_image,   class_name: 'Image'
  belongs_to :master_flavor, class_name: 'Flavor'
  belongs_to :slave_flavor,  class_name: 'Flavor'

  has_many   :cluster_frameworks, dependent: :destroy
  has_many   :frameworks, through: :cluster_frameworks
  has_many   :assignments,        dependent: :destroy

  validates :name,            presence: true, length: { maximum: 255 }
  validates :master_image,    presence: true
  validates :slave_image,     presence: true
  validates :master_flavor,   presence: true
  validates :slave_flavor,    presence: true
  validates :slave_num,       presence: true, numericality: { greater_than: 0 }

  # Updates state and broadcasts to the ActionCable ClusterChannel
  def update(id, uuid, state)
    self.update_attribute(:state, state)
    ActionCable.server.broadcast "user_#{id}",
                                  uuid:  uuid,
                                  state: state
  end

  def suspend(password)
    #TODO: set cluster to suspended
    puts "suspending cluster "+self.uuid
    runstate_req(self.infrastructure, password, self.uuid, "suspend")
  end

  def resume(password)
    #TODO: set cluster to running
    puts "suspending cluster "+self.uuid
    runstate_req(self.infrastructure, password, self.uuid, "resume")
  end

  # Parses uuid from the response header and updates cluster's uuid
  def get_uuid(header)
    uuid = nil
    header.each_header { |key, value| uuid = value.split(//).last(36).join if key =="location" }
    self.update_attribute(:uuid, uuid)
  end
end
