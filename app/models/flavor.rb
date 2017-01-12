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
# Flavor model relationships and validations.
class Flavor < ApplicationRecord
  belongs_to :infrastructure

  has_many :of_master, class_name: 'Cluster', foreign_key: 'master_flavor_id'
  has_many :of_slave,  class_name: 'Cluster', foreign_key: 'slave_flavor_id'

  validates :fl_id, presence: true
  validates :name,  presence: true
  validates :vcpus, presence: true
  validates :disk,  presence: true
  validates :ram,   presence: true
end
