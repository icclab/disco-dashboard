class CreateFlavors < ActiveRecord::Migration[5.0]
  def change
    create_table :flavors do |t|
      t.string :fl_id
      t.string :name
      t.integer :vcpus
      t.integer :disk
      t.integer :ram
      t.references :infrastructure, foreign_key: true

      t.timestamps
    end
  end
end
