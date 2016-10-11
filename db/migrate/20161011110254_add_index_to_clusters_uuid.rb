class AddIndexToClustersUuid < ActiveRecord::Migration[5.0]
  def change
    add_index :clusters, :uuid, unique: true
  end
end
