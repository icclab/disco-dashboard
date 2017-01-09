class CreateClusters < ActiveRecord::Migration[5.0]
  def change
    create_table :clusters do |t|
      t.string  :uuid
      t.string  :state, default: "DEPLOYING"
      t.string  :name
      t.integer :master_image_id
      t.integer :slave_image_id
      t.integer :master_flavor_id
      t.integer :slave_flavor_id
      t.integer :master_num
      t.integer :slave_num
      t.integer :external_ip, limit: 8, default: 0
      t.boolean :slave_on_master
      t.references :infrastructure, foreign_key: true

      t.timestamps
    end
    add_index :clusters, :uuid, unique: true
  end
end
