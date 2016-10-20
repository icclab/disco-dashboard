class CreateImages < ActiveRecord::Migration[5.0]
  def change
    create_table :images do |t|
      t.string :img_id
      t.string :name
      t.integer :size
      t.references :infrastructure, foreign_key: true

      t.timestamps
    end
  end
end
