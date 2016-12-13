class Cluster < ApplicationRecord
  belongs_to :infrastructure
  belongs_to :group, optional: true
  has_many   :cluster_frameworks, dependent: :destroy
  has_many   :assignments,        dependent: :destroy

  validates :name,            presence: true, length: { maximum: 255 }
  validates :master_image,    presence: true
  validates :slave_image,     presence: true
  validates :master_flavor,   presence: true
  validates :slave_flavor,    presence: true
  validates :master_num,      presence: true, numericality: { greater_than: 0 }
  validates :slave_num,       presence: true, numericality: { greater_than: 0 }
  validates_inclusion_of :slave_on_master, :in => [true, false]

  def update(id, uuid, state)
    ActionCable.server.broadcast "user_#{id}",
                                  type:  2,
                                  uuid:  uuid,
                                  state: state
  end
end
