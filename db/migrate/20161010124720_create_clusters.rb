class CreateClusters < ActiveRecord::Migration[5.0]
  def change
    create_table :clusters do |t|
      t.string  :uuid
      t.string  :state
      t.string  :name
      t.string  :master_image
      t.string  :slave_image
      t.string  :master_flavor
      t.string  :slave_flavor
      t.integer :master_num
      t.integer :slave_num
      t.integer :external_ip, limit: 8
      t.boolean :slave_on_master
      t.references :infrastructure, foreign_key: true

      t.timestamps
    end
    add_index :clusters, :uuid, unique: true
  end
end
