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
