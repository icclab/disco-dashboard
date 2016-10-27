class CreateClusterFrameworks < ActiveRecord::Migration[5.0]
  def change
    create_table :cluster_frameworks do |t|
      t.belongs_to :cluster
      t.references :framework
      t.timestamps
    end
  end
end
