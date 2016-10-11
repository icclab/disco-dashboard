class AddSomeColumnsToClusters < ActiveRecord::Migration[5.0]
  def change
    add_column :clusters, :external_ip, :integer
  end
end
