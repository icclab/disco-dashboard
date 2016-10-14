class Cluster < ApplicationRecord
  belongs_to :user

  def update(id, uuid, state)
    ActionCable.server.broadcast "cluster_#{id}",
                                         type: 2,
                                         uuid: '#cluster-'+uuid,
                                         state: state
  end
end
