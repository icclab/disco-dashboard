class Cluster < ApplicationRecord
  belongs_to :infrastructure

  def update(id, uuid, state)
    puts "====================================================================="
    puts "                  State of cluster#{uuid} was updated"
    puts "====================================================================="
    ActionCable.server.broadcast "cluster_#{id}",
                                         type: 2,
                                         uuid: '#cluster-'+uuid,
                                         state: state
  end
end
