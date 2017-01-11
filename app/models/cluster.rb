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
  validates :master_num,      presence: true, numericality: { greater_than: 0 }
  validates :slave_num,       presence: true, numericality: { greater_than: 0 }
  validates_inclusion_of :slave_on_master, :in => [true, false]

  # Updates state and broadcasts to the ActionCable ClusterChannel
  def update(id, uuid, state)
    self.update_attribute(:state, state)
    ActionCable.server.broadcast "user_#{id}",
                                  uuid:  uuid,
                                  state: state
  end

  # Parses uuid from the response header and updates cluster's uuid
  def get_uuid(header)
    uuid = nil
    header.each_header { |key, value| uuid = value.split(//).last(36).join if key =="location" }
    self.update_attribute(:uuid, uuid)
  end
end
