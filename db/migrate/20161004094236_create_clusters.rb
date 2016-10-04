class CreateClusters < ActiveRecord::Migration[5.0]
  def change
    create_table :clusters do |t|
      t.string :name
      t.string :master_name
      t.string :slave_name
      t.integer :master_num
      t.integer :slave_num
      t.string :master_image
      t.string :master_flavor
      t.string :slave_image
      t.string :slave_flavor
      t.boolean :master_slave

      t.timestamps
    end
  end
end
