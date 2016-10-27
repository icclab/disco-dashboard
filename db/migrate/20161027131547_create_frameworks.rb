class CreateFrameworks < ActiveRecord::Migration[5.0]
  def change
    create_table :frameworks do |t|
      t.string :name
      t.string :description
      t.string :port
      t.timestamps
    end
  end
end
