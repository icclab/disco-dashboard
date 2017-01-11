##
# Image model relationships and validations.
class Image < ApplicationRecord
  belongs_to :infrastructure

  has_many :of_master, class_name: 'Cluster', foreign_key: 'master_image_id'
  has_many :of_slaves, class_name: 'Cluster', foreign_key: 'slave_image_id'

  validates :img_id, presence: true
  validates :name,   presence: true
end
