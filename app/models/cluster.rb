class Cluster < ApplicationRecord
  belongs_to :infrastructure
  has_many   :cluster_frameworks, dependent: :destroy
  has_many   :assignments,        dependent: :destroy
  has_many   :users, through: :assignments, dependent: :destroy

  validates :name,            presence: true, length: { maximum: 255 }
  validates :master_image,    presence: true
  validates :slave_image,     presence: true
  validates :master_flavor,   presence: true
  validates :slave_flavor,    presence: true
  validates :master_num,      presence: true
  validates :slave_num,       presence: true
  validates :slave_on_master, presence: true

  def update(id, uuid, state)
    ActionCable.server.broadcast "cluster_#{id}",
                                         type: 2,
                                         uuid: '#cluster-'+uuid,
                                         state: state
  end
end
