class ChangeIntegerLimitInClusters < ActiveRecord::Migration[5.0]
  def change
    change_column :clusters, :external_ip, :integer, limit: 8
  end
end
