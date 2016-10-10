class CreateClusters < ActiveRecord::Migration[5.0]
  def change
    create_table :clusters do |t|
      t.string :uuid
      t.string :state
      t.references :user, foreign_key: true

      t.timestamps
    end
    add_index :clusters, [:user_id, :uuid]
  end
end
