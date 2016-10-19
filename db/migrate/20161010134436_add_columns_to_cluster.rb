class AddColumnsToCluster < ActiveRecord::Migration[5.0]
  def change
    add_column :clusters, :name, :string
    add_column :clusters, :master_image, :string
    add_column :clusters, :slave_image, :string
    add_column :clusters, :master_flavor, :string
    add_column :clusters, :slave_flavor, :string
    add_column :clusters, :master_num, :integer
    add_column :clusters, :slave_num, :integer
    add_column :clusters, :slave_on_master, :boolean
  end
end
