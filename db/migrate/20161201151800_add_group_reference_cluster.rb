class AddGroupReferenceCluster < ActiveRecord::Migration[5.0]
  def change
    add_reference :clusters, :group, index: true
  end
end
